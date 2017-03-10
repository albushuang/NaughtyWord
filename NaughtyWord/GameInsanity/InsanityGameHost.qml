import QtQuick 2.0
import com.glovisdom.AnkiDeck 0.1
import AppSettings 0.1
import QtQuick.LocalStorage 2.0 as Sql
import com.glovisdom.UserSettings 0.1
import "ModelSettingsInInsanity.js" as Consts
import "settingValues.js" as Value
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalModel"
import "../generalJS/generalConstants.js" as GeneralConsts
import "../generalJS/chooseDeck.js" as Choose

Item{
    property alias isSmallerCoolDown: gameHost.isSmallerCoolDown
    property alias score: gameHost.score
    property alias addtionalCoins: gameHost.addtionalCoins
    property alias timeDuration: gameHost.timeDuration
    property alias currQuestIdx: gameHost.currQuestIdx
    property alias currQuestion: gameHost.currQuestion  //Only use in gameMode = spelling
    property alias currentAlphabetIdx: gameHost.currentAlphabetIdx  //Only use in gameMode = spelling
    property alias availableChoices: gameHost.availableChoices
    property alias correctCount: gameHost.correctCount
    property alias scoreMultiplexer: gameHost.scoreMultiplexer
    property alias ongoingPowerUps: gameHost.ongoingPowerUps
    property alias powerUpEnabled: gameHost.powerUpEnabled
    property alias insanitySettings: insanitySettings
    property alias getRootPath: gameHost.getRootPath
    signal gameOver()
    signal newPowerUp(variant powerUp)
    signal newPowerUpHint(variant powerUp, int milliSec)
    signal powerUpEnd(variant powerUp)
    signal powerUpEndHint(variant powerUp, int milliSec)
    signal insanitySettingsReady(variant settings)

    function startGame(){
        return gameHost.startGame()
    }
    function handleSelection(index){
        return gameHost.handleSelection(index)
    }
    function getHighScores(){
        return gameHost.getHighScores()
    }
    function collideObstacle(){
        return gameHost.collideObstacle()
    }
    function resetGame(){
        return gameHost.resetGame()
    }
    function pauseGame(){
        return gameHost.pauseGame()
    }
    function resumeGame(){
        return gameHost.resumeGame()
    }
    function speechClicked(id){
        return gameHost.deckMedia.speechClicked(id)
    }
    function getDbIdentifier() {
        return gameHost.getDbIdentifier();
    }
    function getHeaderInfoEements(){
        return gameHost.getHeaderInfoEements()
    }

    function settingUpdated(settings){
        return gameHost.settingUpdated(settings)
    }

    Item {
        id: gameHost
        property var getRootPath
        property int score: 0
        property int addtionalCoins: 0
        property int timeDuration: 0
        property int currQuestIdx
        property variant currQuestion     //Only use in gameMode = spelling
        property int currentAlphabetIdx   //Only use in gameMode = spelling
        property variant availableChoices: []
        property variant nextAvailableChoices: []
        property int numberOfChoice: 0
        property int correctCount: 0
        property variant cardNeedToBeUpdated:[]
        property real scoreMultiplexer: 1
        property variant ongoingPowerUps: []
        property variant nextPowerUp
        property int powerUpTimer: 0
        property bool powerUpEnabled: true
        property bool isSmallerCoolDown: true
        property var deckMedia

        InsanitySettings{id: insanitySettings
            Component.onCompleted: {
                insanitySettingsReady(insanitySettings)
            }
        }

        AppSettings { id: appSettings }  //We can get app default file path from C++

        Component.onCompleted: {
            deckMedia = Choose.createMedia(gameHost,
                                           appSettings.readSetting(AppKeys.pathInSettings),
                                           { deck: UserSettings.gameDeck, soundON: UserSettings.soundGameON,
                                             picOnly: true})
            deckMedia.cardsReady.connect(handleCardsReady)
            getRootPath = deckMedia.getRootPath
        }
        Component.onDestruction: {
            deckMedia.destroy()
        }
        Timer{
            id: durationTimer
            interval: 100
            repeat: true
            onTriggered:{
                score++
                timeDuration += 100
                if(powerUpEnabled){
                    for(var i = 0; i < ongoingPowerUps.length; i++){
                        ongoingPowerUps[i].timer -= 100;
                        if(ongoingPowerUps[i].timer <= 0){
                            gameHost.deletePowerUp(i);
                        }else if(ongoingPowerUps[i].timer > Consts.endPowerUpHintTime - 50 &&
                                 ongoingPowerUps[i].timer <= Consts.endPowerUpHintTime +50){
                            powerUpEndHint(ongoingPowerUps[i], Consts.endPowerUpHintTime);
                        }
                    }

                    gameHost.powerUpTimer -= 100;
                    if(gameHost.powerUpTimer > Consts.newPowerUpHintTime - 50 &&
                            gameHost.powerUpTimer <= Consts.newPowerUpHintTime + 50){
                        gameHost.randomNextPowerUp();
                        newPowerUpHint(gameHost.nextPowerUp, Consts.newPowerUpHintTime);
                    }
                    if(gameHost.powerUpTimer < 0){
                        gameHost.broodPowerUp();
                        gameHost.setNextPowerUpTimer();
                    }
                }
            }
        }

        Timer{
            id: multiThreadTimerOfFetchCards    //Make time consuming task be executed later
            interval: 30
            running: false
            onTriggered: {
                gameHost.prepareNextAvailableChoices(gameHost.getFilter())
            }
        }
        Timer{
            id: multiThreadTimerOfUpdateCards    //Make time consuming task be executed later
            interval: 90
            running: false
            onTriggered: {
                gameHost.updateCardToDB()
            }
        }

        function startGame(){
            var result = setUpTheNewQuestion()            
            if(result.value){
                saveGameUsageRecords()
                setNextPowerUpTimer()
                durationTimer.start()                
            }
            return result
        }

        function setUpTheNewQuestion(){
            var filter = getFilter()
            var prevId
            var result
            switch(insanitySettings.gameType){
            case Value.image:
                prevId = availableChoices.length > 0 ? availableChoices[currQuestIdx].id : 0
                releaseAvailableChoices()

                result = fillAvailableChoices(filter)
                if(result.value == true){
                    chooseQuestion(prevId, filter)
                }
                break;
            case Value.spelling:
                if(typeof(currQuestion) != "undefined"){
                    prevId = currQuestion.id
                    deckMedia.releaseCard(currQuestion)
                }else{
                    prevId = 0
                }

                result = fillCurrQuestion(prevId, filter)
                if(result.value){
                    currentAlphabetIdx = 0
                    fillAlphabetChoices()
                }
            }
            if(result.value){
                multiThreadTimerOfFetchCards.restart()
            }

            return result
        }

        function fillAvailableChoices(filter){  //For game mode: image
            if(nextAvailableChoices.length != 0){
                availableChoices = nextAvailableChoices
                nextAvailableChoices = []
            }else{
                console.log("fail to prepare card asynchronize")
                var order = AnkiDeck.Random, orderTarget = "";
                availableChoices = deckMedia.fetchCards(numberOfChoice, filter, order, orderTarget)
            }

            if(availableChoices.length < numberOfChoice){
                resetGame()
                var warningLog
                switch(insanitySettings.cardType){
                case GeneralConsts.gameAllWordID:
                    warningLog = GeneralConsts.warnDeckLackCard.arg(availableChoices.length).arg(numberOfChoice)
                    break;
                case GeneralConsts.gameTodayPracticedID:
                    warningLog = GeneralConsts.warnPracticedTodayLackCard
                        .arg(GeneralConsts.stringCardType[GeneralConsts.gameTodayPracticedID])
                        .arg(numberOfChoice).arg(GeneralConsts.txtGameQuestionPool)
                    break;
                case GeneralConsts.gameAllPracticedID:
                    warningLog = GeneralConsts.warnAllPracticedLackCard
                        .arg(GeneralConsts.stringCardType[GeneralConsts.gameAllPracticedID])
                        .arg(numberOfChoice).arg(GeneralConsts.txtGameQuestionPool)
                    break;
                default: console.assert(false, "Must be some typo inside code for cardType")
                }
                return {
                    value: false,
                    log: warningLog
                }
            }
            return {
                value: true,
                log: ""
            }
        }

        function handleCardsReady(cards){
            nextAvailableChoices = cards
        }

        function prepareNextAvailableChoices(filter){
            releaseCards(nextAvailableChoices)

            var order = AnkiDeck.Random, orderTarget = "", aheadDays = 0;
            deckMedia.fetchCardsAsync(numberOfChoice, filter, order, orderTarget, aheadDays)
        }
//TODO 還沒把"難的優先"的出題改成async
        function chooseQuestion(prevId, filter){      //For game mode: image
            if(insanitySettings.dealingType == GeneralConsts.gameRandomID){
                do{
                    currQuestIdx = Math.floor((Math.random() * numberOfChoice) )
                }while(availableChoices[currQuestIdx].id == prevId)
            }else if(insanitySettings.dealingType ==  GeneralConsts.gamePracticeID){
                var order = AnkiDeck.ASC
                var orderTarget = "ef"
                var hardQuestions, idx

                do{
                    if(typeof(hardQuestions) == "undefined"){
                        hardQuestions = deckMedia.fetchCards(Consts.numOfHardQstToRand, filter, order, orderTarget)
                    }
                    idx = Math.floor((Math.random() * Consts.numOfHardQstToRand) )
                }while(hardQuestions[idx].id == prevId && Consts.numOfHardQstToRand != 1)

                releaseHardCards(idx, hardQuestions);

                for(var i = 0; i< availableChoices.length; i ++){
                    if(hardQuestions[idx].id == availableChoices[i].id){
                        currQuestIdx = i
                        return
                    }
                }

                currQuestIdx = Math.floor((Math.random() * numberOfChoice) )
                deckMedia.releaseCard(availableChoices[currQuestIdx])
                availableChoices.splice(currQuestIdx,1,hardQuestions[idx])
            }
            else{
                console.assert(false, "dealingType is wrong")
            }
        }

        function releaseHardCards(chosenIdx, hardQuestions) {
            for(var i = 0; i< hardQuestions.length; i ++){
                if(i != chosenIdx){
                    for (var j=0; j<availableChoices.length; j++) {
                        if (hardQuestions[i].id == availableChoices[j].id) { break; }
                    }
                    if (j>=availableChoices.length) { deckMedia.releaseCard(hardQuestions[i]); }
                }
            }
        }

        function fillCurrQuestion(prevId, filter){  //For game mode: SpellingChoices
            var order, orderTarget

            if(insanitySettings.dealingType == GeneralConsts.gameRandomID){
                order = AnkiDeck.Random
                orderTarget = ""
                do{
                    currQuestion = deckMedia.fetchCards(1, filter, order, orderTarget)[0]
                    if(typeof(currQuestion) == "undefined"){
                        return {
                            value: false,
                            log: qsTr("insufficient cards")
                        }
                    }
                    if(currQuestion.id == prevId){
                        deckMedia.releaseCard(currQuestion)
                    }
                }while(currQuestion.id == prevId)
            }else if(insanitySettings.dealingType == GeneralConsts.gamePracticeID){
                order = AnkiDeck.ASC
                orderTarget = "ef"
                var hardQuestions, idx

                do{
                    if(typeof(hardQuestions) == "undefined"){
                        hardQuestions = deckMedia.fetchCards(Consts.numOfHardQstToRand, filter, order, orderTarget)
                        if(hardQuestions.length < Consts.numOfHardQstToRand){
                            return {
                                value: false,
                                log: qsTr("insufficient cards")
                            }
                        }
                    }
                    idx = Math.floor((Math.random() * Consts.numOfHardQstToRand) )
                }while(hardQuestions[idx].id == prevId && Consts.numOfHardQstToRand != 1)

                for(var i = 0; i< hardQuestions.length; i ++){
                    if(i != idx){
                        deckMedia.releaseCard(hardQuestions[i])
                    }
                }

                currQuestion = hardQuestions[idx]
            }
            else{
                console.assert(false, "dealingType is wrong")
            }

            return {
                value: true,
                log: ""
            }

        }

        function fillAlphabetChoices(){  //For game mode: SpellingChoices
            var word = currQuestion.word
            availableChoices = []

            currQuestIdx = Math.floor((Math.random() * numberOfChoice) )
            var questionLetter = word.toLocaleLowerCase().charAt(currentAlphabetIdx)
            for(var i = 0; i < numberOfChoice ; i++){
                if(i == currQuestIdx){
                    availableChoices[i] = questionLetter
                }else{
                    availableChoices[i] = pickUpALetterFor(questionLetter)
                    for(var j = 0; j < i; j++){
                        if(availableChoices[i] == availableChoices[j]){
                            i--
                            break
                        }
                    }
                }
            }
        }

        function pickUpALetterFor(letter){
            console.assert(numberOfChoice <= 5, "Too many choices, we don't have enough vowel")
            var vowel = "aeiou"
            var consonant = "bcdfghjklmnpqrstvwxyz"
            var candidateStr = ""
            if(vowel.search(letter) != -1){
                candidateStr = vowel.replace(letter,"")
            }else{
                candidateStr = consonant.replace(letter,"")
            }

            return candidateStr.charAt(Math.floor(Math.random()* candidateStr.length))
        }

        function releaseAvailableChoices(){
            for(var i = 0; i < availableChoices.length; i++){
                var releasable = true
                for(var j = 0; j < nextAvailableChoices.length; j++){
                    if(availableChoices[i].id == nextAvailableChoices[j].id){
                        releasable = false
                        break
                    }
                }
                if(releasable){
                    deckMedia.releaseCard(availableChoices[i])
                }
            }
        }

        function getFilter(){
            switch(insanitySettings.cardType){
            case GeneralConsts.gameAllWordID: return AnkiDeck.All; break;
            case GeneralConsts.gameTodayPracticedID: return AnkiDeck.StudyToday; break;
            case GeneralConsts.gameAllPracticedID: return AnkiDeck.StatusReview; break;
            default: console.assert(false, "Must be some typo inside code for cardType")
            }
        }

        function handleSelection(index){
            var result = currQuestIdx == index
            updateScore(result)
//            updateCardEasinessFactor(result, index)

            switch(insanitySettings.gameType){
            case Value.image:
                setUpTheNewQuestion()
                break;
            case Value.spelling:
                if(result){
                    currentAlphabetIdx++
                    if(currentAlphabetIdx == currQuestion.word.length){
                        setUpTheNewQuestion()
                    }else{
                        fillAlphabetChoices()
                    }
                }
                break;
            }

            return result
        }


        function updateScore(result){                        
            correctCount += result? 2: -1
            correctCount = Math.max(0, correctCount)
            score += Math.round(correctCount*scoreMultiplexer) * (result ? 1 : -1)
            score = Math.max(0, score)
        }



        function updateCardEasinessFactor(result, index){
            switch(insanitySettings.gameType){
            case Value.image:
                availableChoices[currQuestIdx].ef += result ? 0.05 : -0.05
                availableChoices[currQuestIdx].ef = Math.max(1.3, availableChoices[currQuestIdx].ef)
                cardNeedToBeUpdated.push(availableChoices[currQuestIdx])
                if(!result){
                    availableChoices[index].ef += -0.05
                    availableChoices[index].ef = Math.max(1.3, availableChoices[index].ef)
                    cardNeedToBeUpdated.push(availableChoices[index])
                }
                break;
            case Value.spelling:
                currQuestion.ef += result ? 0.01 : - 0.01
                currQuestion.ef = Math.max(1.3, currQuestion.ef)
                cardNeedToBeUpdated.push(currQuestion)
                break;
            }

            multiThreadTimerOfUpdateCards.restart()
        }

        function updateCardToDB(){
            for(var i = cardNeedToBeUpdated.length - 1; i >= 0 ; i--){
                deckMedia.updateCardAsync(cardNeedToBeUpdated[i], ["ef"])
                cardNeedToBeUpdated.pop()
            }
        }

        function randomNextPowerUp(){
            var present = Math.floor(Math.random() * 100);
            for(var i = 0; i < Consts.powerUps.length; i++){
                present -= Consts.powerUps[i].probability;
                if(present < 0){
                    nextPowerUp = Consts.powerUps[i];
                    break;
                }
            }
        }

        function broodPowerUp(){
            var index = findPowerUpIdx(nextPowerUp.type);
            if(index == -1){
                if(nextPowerUp.timer != 0){
                    //Cannot push nextPowerUp because it's an object (copy by reference)
                    ongoingPowerUps.push(Object.create(nextPowerUp));
                }
                //Most powerUp handling are done by viewController because they are all about view manipulation
                newPowerUp(nextPowerUp);
                powerUpHandler(nextPowerUp, true); //Some powerUps which are UI independent are handled here
            }else{
                ongoingPowerUps[index].timer = nextPowerUp.timer;
            }
        }

        function deletePowerUp(index){
            powerUpEnd(ongoingPowerUps[index]);
            powerUpHandler(ongoingPowerUps[index], false);
            ongoingPowerUps.splice(index,1);
        }

        function powerUpHandler(powerUp, enabling){
            switch(powerUp.type){
            case "redBull":
                if(enabling){
                    scoreMultiplexer = powerUp.effect;
                }else{
                    scoreMultiplexer = 1
                }
                break;
            }
        }

        function findPowerUpIdx(type){
            for(var i = 0; i < ongoingPowerUps.length; i++){
                if(ongoingPowerUps[i].type == type){
                    return i
                }
            }
            return -1
        }

        function setNextPowerUpTimer(){
            var lowerRandonValue = Consts.powerUpTimerRandomRange[0]
            var higherRandonValue = Consts.powerUpTimerRandomRange[1]
            powerUpTimer = Math.random() * (higherRandonValue - lowerRandonValue) + lowerRandonValue
//            console.log("Next power up will be in", powerUpTimer, "second")
        }

        function settingUpdated(settings){
            Consts.init(settings)
            gameHost.numberOfChoice =  Consts.numberOfChoice
        }

        function resetGame(){
            score = 0
            correctCount = 0
            timeDuration = 0
            isSmallerCoolDown = true
            availableChoices = []
            durationTimer.stop()
            for(var i = 0; i < ongoingPowerUps.length; i++){
                deletePowerUp(i);
            }
            releaseCards(availableChoices)
            prepareNextAvailableChoices(getFilter())
        }

        function getHighScores(){
            return DbHandler.getHighScores(getDbIdentifier())
        }

        function getDbIdentifier(){
            return ["Insanity", insanitySettings.cardType, deckMedia.getDeckID()]
        }

        function getHeaderInfoEements() {
            return [{infoTitle: GeneralConsts.txtGameQuestionPool,
                        information: GeneralConsts.stringCardType[insanitySettings.cardType] },
                    {infoTitle: GeneralConsts.deck, information: deckMedia.getDeck().split(".")[0] },
                    {infoTitle: GeneralConsts.txtScore, information: score.toString() },
                    {infoTitle: qsTr("Coins"), information: addtionalCoins.toString()}]
        }

        function collideObstacle(){
            updateCoins();
            gameOver()
            durationTimer.stop()            
        }

        function releaseCards(cards){
            for(var i = 0; i < cards.length; i++){
                deckMedia.releaseCard(cards[i])
            }
            cards= []
        }

        function updateCoins(){
            switch(insanitySettings.easiness){
            case GeneralConsts.gameHardID: addtionalCoins = score; break;
            case GeneralConsts.gameMediumID:
                addtionalCoins = Math.round(Math.min(score * Consts.coinRatioWithLvMeduim, Consts.maxCoinsWithLvMedium));
                break;
            case GeneralConsts.gameEasyID:
                addtionalCoins = Math.round(Math.min(score * Consts.coinRatioWithLvEasy, Consts.maxCoinsWithLvEasy));
                break;
            }
            UserSettings.coins += addtionalCoins;
        }
        function pauseGame(){
            durationTimer.stop()
        }
        function resumeGame(){
            durationTimer.restart()
        }

        function saveGameUsageRecords(){
            var deckName = UserSettings.gameDeck.split(".")[0]
            deckName = deckName.replace(/.*\//, "")    //remove "anki/" if it is there
            var gameRecordStr = appSettings.readSetting(AppKeys.gameRecords)
            if(typeof(gameRecordStr) == "object" ){
                /* In old design, appSettings.readSetting(AppKeys.gameRecords) returns an object. In this case,
                we should convert it to string first. In new design, this condition shouldn't be entered. Just for
                backward compatiable*/
                gameRecordStr = JSON.stringify(gameRecordStr)
            }
            var gameRecords = JSON.parse(gameRecordStr)
            if(typeof(gameRecords[deckName].insanity) == "undefined"){
                console.assert( typeof(gameRecords) != "undefined" && typeof(gameRecords[deckName]) != "undefined"
                               , "gameRecords should be initialized already" )
                gameRecords[deckName].insanity = {image: 0, spelling: 0}
            }

            switch(insanitySettings.gameType){
            case Value.image:
                gameRecords[deckName].insanity.image++
                break;
            case Value.spelling:
                gameRecords[deckName].insanity.spelling++
                break;
            default:
                console.assert(false, "Should be one of above modes")
            }

            appSettings.writeSetting(AppKeys.gameRecords, JSON.stringify(gameRecords))
        }
    }

}
