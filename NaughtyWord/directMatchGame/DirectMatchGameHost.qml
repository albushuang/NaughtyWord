import QtQuick 2.0
import com.glovisdom.AnkiDeck 0.1
import AppSettings 0.1
import AnkiPackage 0.1
import QtQuick.LocalStorage 2.0 as Sql
import com.glovisdom.UserSettings 0.1
import "ModelSettingsInDirectMatchGame.js" as Consts
import "settingValues.js" as Value
import "../generalJS/appsettingKeys.js" as AppKeys
import "../GamePractice/SuperMemoAlgorithm.js" as Algor
import "../generalModel"
import "../generalJS/generalConstants.js" as GeneralConsts
import "../generalJS/chooseDeck.js" as Choose
import "../generalJS/synonymAntonymHandler.js" as SynoHandler

Item{
    property alias score: gameHost.score
    property alias timeDuration: gameHost.timeDuration
    property alias currQuestIdx: gameHost.currQuestIdx
    property alias availableChoices: gameHost.availableChoices
    property alias lifeRatio: gameHost.lifeRatio
    property alias wasWrong: gameHost.wasWrong
    property alias directMatchGameSettings: directMatchGameSettings
    property alias answerType: gameHost.answerType
    property alias questionType: gameHost.questionType
    signal gameOver()
    signal finishAllPractice()
    signal newQuestionReady()
    signal directMatchGameSettingsReady(variant settings)

    property alias halfWordLeftIdx: gameHost.halfWordLeftIdx
    property alias halfWordRightIdx: gameHost.halfWordRightIdx
    property alias halfCorrect: gameHost.halfCorrect
    property alias getRootPath: gameHost.getRootPath
    property alias studiedNew: gameHost.studiedNew
    property alias studiedReview: gameHost.studiedReview
    property alias timesSameQuesClick: gameHost.timesSameQuesClick

    function startGame(){
        return gameHost.startGame()
    }
    function handleSelection(index){
        return gameHost.handleSelection(index)
    }
    function getHighScores(){
        return gameHost.getHighScores()
    }
    function getDbIdentifier() {
        return gameHost.getDbIdentifier();
    }
    function getHeaderInfoEements(){
        return gameHost.getHeaderInfoEements()
    }
    function dontKnowAnswer(){
        return gameHost.dontKnowAnswer();
    }
    function settingUpdated(settings){
        return gameHost.settingUpdated(settings)
    }
    function halfWordStatusReset(){
        return gameHost.halfWordStatusReset()
    }
    function stopGameTimer(){
        return gameHost.stopGameTimer()
    }
    function restartGameTimer(){
        return gameHost.restartGameTimer()
    }
    function hideHalfCorrectHint(){
        return gameHost.hideHalfCorrectHint()
    }
    function pullInScheduleAndResumeGame(){
        return gameHost.pullInScheduleAndResumeGame()
    }

    Item {
        id: gameHost
        property var getRootPath: deckMedia.getRootPath
        property int score: 0
        property int timeDuration: 0
        property int timeThisQuestStart: 0
        property variant cards
        property int currQuestIdx: 0
        property variant availableChoices
        property int numberOfChoice: 0
        property real fullOneRoundTimer: 0
        property real oneRoundTimer: 0
        property real lifeRatio: 1
        property bool wasWrong: false
        property var deckMedia
        property int answerType
        property int questionType
        property int studiedNew: 0
        property int studiedReview: 0
        property int correctCount: 0
        property int timesSameQuesClick: 0

// for halfWordHalfImage
        property bool halfCorrect: false
        property int halfWordLeftIdx: 0
        property int halfWordRightIdx: 0
        property bool halfWordLeftCorrect: false
        property bool halfWordRightCorrect: false
        property bool twiceFirstCorrect: false

// for twice a Question
        property bool newQuestion: false

        DirectMatchGameSettings{id: directMatchGameSettings
            Component.onCompleted: {
                directMatchGameSettingsReady(directMatchGameSettings)
            }
        }

        AppSettings { id: appSettings }


        Component.onCompleted: {
            deckMedia = Choose.createMedia(gameHost,
                                           appSettings.readSetting(AppKeys.pathInSettings),
                                           { deck: UserSettings.gameDeck, soundON: UserSettings.soundGameON })
        }

        Timer{
            id: durationTimer
            interval: 50
            repeat: true
            onTriggered:{
                timeDuration += 50
                gameHost.oneRoundTimer -= 50
                gameHost.oneRoundTimer = Math.max(0, gameHost.oneRoundTimer)
                gameHost.fullOneRoundTimer -= 5
                gameHost.lifeRatio = gameHost.oneRoundTimer/gameHost.fullOneRoundTimer
            }
        }

        Timer {
            id: gameOverTimer
            interval: gameHost.oneRoundTimer
            onTriggered: {
                gameOver()
                durationTimer.stop()
                if(Algor.numberOfAheadDays > 0){
                    deckMedia.pullInPractice()
                    Algor.setNumberOfAheadDays(0)
                }
            }
        }

        Timer { id: delayUpdateQuestion; interval: Consts.longPenaltyTime
            onTriggered: {gameHost.setUpTheNewQuestion()}
        }

        Timer { id: speechBinding
            interval: 100; repeat: false
            property string theID;
            onTriggered: {
                parent.deckMedia.speechClicked(theID);
            }
            function playSpeech(id){
                speechBinding.theID = id;
                start();
            }
        }

        function stopGameTimer(){
            durationTimer.stop();
            gameOverTimer.stop();
        }

        function restartGameTimer(){
            durationTimer.restart();
            gameOverTimer.restart();
        }

        function startGame(){
            resetGame()
            var result = setUpTheNewQuestion()
            if(result.value){
                saveGameUsageRecords()
                durationTimer.start()
            }
            return result
        }

        function hideHalfCorrectHint(){
            myMainView.halfCorrectLeftHint.visible = false
            myMainView.halfCorrectRightHint.visible = false
        }

        function releaseAvailableChoice(){
            for(var i = 0; i < availableChoices.length; i++){
                deckMedia.releaseCard(availableChoices[i])
            }
        }

        function twiceSetUpTheNewQues(){
            newQuestion = !newQuestion
            var prevId = availableChoices.length > 0 ? availableChoices[currQuestIdx].id : 0
            if(newQuestion){
                twiceFirstCorrect = false
                releaseAvailableChoice()
                timeThisQuestStart = timeDuration
            }
            var filter = getFilter()
            var result = fillAvailableChoices(filter)
            if(result.value == true){
                wasWrong = false;
                if(newQuestion){
                    if(!chooseQuestion(prevId, filter)){return result}  //if fail, means we finish today's study. Skip the rest part
                    answerType = Value.answerMeaningsID
                }else{
                    answerType = Value.answerImagesID
                    twiceQuesNewOrder();
                }
                newQuestionReady();
                gameOverTimer.start()
                if(answerType != Value.answerWordsID){//It's like cheating. Not good for learning
                    speechBinding.playSpeech(availableChoices[currQuestIdx].speech)
                }
            }
            return result
        }

        function generalSetUpTheNewQues(){
            if(Consts.directMatchMode == Value.halfWordsID) hideHalfCorrectHint()
            newQuestion = true
            var prevId = availableChoices.length > 0 ? availableChoices[currQuestIdx].id : 0
            releaseAvailableChoice()
            var filter = getFilter()
            var result = fillAvailableChoices(filter)

            if(result.value == true){
                wasWrong = false;
                if(!chooseQuestion(prevId, filter)){return result}  //if fail, means we finish today's study. Skip the rest part
                if(Consts.directMatchMode == Value.halfWordsID){ assignHalfWordOrder(); }
                newQuestionReady();
                timeThisQuestStart = timeDuration
                gameOverTimer.start()
                if(answerType != Value.answerWordsID){//It's like cheating. Not good for learning
                    speechBinding.playSpeech(availableChoices[currQuestIdx].speech)
                }                
            }
            return result
        }

        function setUpTheNewQuestion(){
            switch (Consts.directMatchMode){
            case Value.halfWordsID: hideHalfCorrectHint(); return generalSetUpTheNewQues(); break;
            case Value.twiceQuesID: return twiceSetUpTheNewQues(); break;
            case Value.originalID:  return generalSetUpTheNewQues(); break;
            default: console.assert("Wrong DirectMatchMode"); break;
            }
        }

        function assignHalfWordOrder(){
            var temp = []
            var tempQuesID = availableChoices[currQuestIdx].id
            for(var i = 0; i < numberOfChoice/2; i++){
                temp[i] = availableChoices[i]
            }
            for(var k = 0; k < numberOfChoice/2; k++){
                availableChoices[k*2] = temp[k]
            }
            for( var n = 0; n < numberOfChoice/2; n++ ){
                var j = Math.floor((Math.random() * temp.length))
                availableChoices[n*2+1] = temp[j]
                temp.splice(j,1)
            }
            updateCurrQuesIdx(tempQuesID)
            for(var x = 0; x < availableChoices.length; x += 2){
                if(availableChoices[x].id === tempQuesID)
                    halfWordLeftIdx = x
                if(availableChoices[x+1].id === tempQuesID)
                    halfWordRightIdx = x+1
            }
        }

        function twiceQuesNewOrder(){
            var temp = []
            var tempQuesID = availableChoices[currQuestIdx].id
            for(var i = 0; i< numberOfChoice; i++){
                temp[i] = availableChoices[i]
            }
            for(var k = 0; k< numberOfChoice; k++){
                var tempIdx
                do{
                    tempIdx = Math.floor((Math.random() * numberOfChoice))
                } while (temp[tempIdx] == '')
                availableChoices[k] = temp[tempIdx]
                temp[tempIdx] = ''
            }
            updateCurrQuesIdx(tempQuesID)
        }

        function updateCurrQuesIdx(tempQuesID){
            for(var i = 0; i< availableChoices.length; i ++){
                if(availableChoices[i].id == tempQuesID){
                    currQuestIdx = i
                    return true
                }
            }
            return false
        }

        function fectchAvailableChoices(filter, order, orderTarget){
            if(Consts.directMatchMode == Value.halfWordsID){
                availableChoices = deckMedia.fetchCards(numberOfChoice/2, filter, order, orderTarget)
            }else{
                availableChoices = deckMedia.fetchCards(numberOfChoice, filter, order, orderTarget)
            }
        }

        function fillAvailableChoices(filter){
            if(newQuestion){
                var order = AnkiDeck.Random, orderTarget = "";
                fectchAvailableChoices(filter, order, orderTarget)
            }
//TODO 從15張到期的卡取6張當選項(due 學習卡＋due 複習卡＋新卡）
            if((Consts.directMatchMode != Value.halfWordsID && availableChoices.length < numberOfChoice)
                    || (Consts.directMatchMode == Value.halfWordsID && availableChoices.length < numberOfChoice/2)){
                var warningLog
                switch(Consts.cardType){
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
                resetGame()
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

        function randomCurrQuesIdx(){
            if(Consts.directMatchMode == Value.halfWordsID)
                currQuestIdx = Math.floor((Math.random() * numberOfChoice/2) )
            else
                currQuestIdx = Math.floor((Math.random() * numberOfChoice) )
        }

        function chooseQuestion(prevId, filter){
            var result
            if(Consts.dealingType == GeneralConsts.gameRandomID){
                do{
                    randomCurrQuesIdx()
                }while(availableChoices[currQuestIdx].id == prevId)
                result = true
            }else if(Consts.dealingType == GeneralConsts.gamePracticeID){
                var questions = Algor.getQuestions(deckMedia, 1, UserSettings.newCardsLeftToday, true)

                if(questions.length == 0){
                    stopGameTimer()
                    finishAllPractice()
                    result = false
//                    console.log("Finish all review and new cards. Pull in practice and get more new cards")
//                    //We cannot pullInPractice because it takes too much time to update DB. Hence, we
//                    //set NumberOfAheadDays, then algorithm knows to find ahead (not due) review cards
//                    var aheadDays = deckMedia.getNumberOfAheadDays()
//                    Algor.setNumberOfAheadDays(aheadDays)//deckMedia.pullInPractice()
//                    UserSettings.newCardsLeftToday = Algor.newCardsPerDay
//                    questions = Algor.getQuestions(deckMedia, 1, UserSettings.newCardsLeftToday, true)
//                    console.assert(questions.length > 0, "We should get card after setting NumberOfAheadDays")
                }else{
                    if (!updateCurrQuesIdx(questions[0].id)){
                        randomCurrQuesIdx()
                        deckMedia.releaseCard(availableChoices[currQuestIdx])
                        availableChoices.splice(currQuestIdx, 1, questions[0])
                    }
                    result = true
                }
            }else{
                result = true
                console.assert(false, "dealingType is wrong")
            }
            return result
        }

        function getFilter(){
            if(Consts.directMatchMode == Value.originalID){
                switch(Consts.cardType){
                case GeneralConsts.gameAllWordID: return AnkiDeck.All; break;
                case GeneralConsts.gameTodayPracticedID: return AnkiDeck.StudyToday; break;
                case GeneralConsts.gameAllPracticedID: return AnkiDeck.StudyAll; break;
                default: console.assert(false, "Must be some typo inside code for cardType")
                }
            }else{
                return AnkiDeck.All
            }
        }

        function halfWordStatusReset(){
            halfWordLeftCorrect = false;
            halfWordRightCorrect = false;
            halfCorrect = false
        }

        function halfHandleSelectionResult(index, result){
            speechBinding.playSpeech(availableChoices[index].speech)
            switch (index){
            case halfWordLeftIdx:
                halfWordLeftCorrect = true;
                halfCorrect = true; break;
            case halfWordRightIdx:
                halfWordRightCorrect = true;
                halfCorrect = true; break;
            default:
                halfCorrect = false; break;
            }
            if( halfWordLeftCorrect && halfWordRightCorrect){
                halfWordStatusReset()
                result = true
            }else result = false

            if(result){
                if(gameHost.wasWrong && !halfCorrect){
                    wasWrongHandleSelection(index)
                }else{
                    updateCardWithUserReply(availableChoices[index], result, timeDuration - timeThisQuestStart)
                    setUpTheNewQuestion()
                }
            }else{
                if(!halfCorrect){
                    updateCardWithUserReply(availableChoices[index], result, timeDuration - timeThisQuestStart)
                    if(!wasWrong){
                        updateCardWithUserReply(availableChoices[currQuestIdx], result, timeDuration - timeThisQuestStart)
                    }
                    speechBinding.playSpeech(availableChoices[index].speech);
                    wasWrong = true;
                }
            }
            return result
        }

        function twiceHandleSelectionResult(index, result){
            result = currQuestIdx == index
            if(result){
                if(newQuestion){
                    if(!wasWrong){
                        twiceFirstCorrect = true
                    }
                }else{
                    if(twiceFirstCorrect){
                        if(!wasWrong){
                            updateCardWithUserReply(availableChoices[index], result, timeDuration - timeThisQuestStart)  //僅在兩次都答對更新題目答對
                        }
                    }
                }
                if(wasWrong){
                    wasWrongHandleSelection(index)
                }else{
                    setUpTheNewQuestion()
                }

            }else{
                updateCardWithUserReply(availableChoices[index], result, timeDuration - timeThisQuestStart) //更新答案答錯
                if(newQuestion){
                    twiceFirstCorrect = false
                    if(!wasWrong){
                        updateCardWithUserReply(availableChoices[currQuestIdx], result, timeDuration - timeThisQuestStart) //僅在第一次答錯更新題目答錯
                        wasWrong = true
                    }
                }else{
                    if(twiceFirstCorrect){
                        if(!wasWrong){
                            updateCardWithUserReply(availableChoices[currQuestIdx], result, timeDuration - timeThisQuestStart) //僅在第一次答錯更新題目答錯
                        }
                    }
                }
                speechBinding.playSpeech(availableChoices[index].speech);
                wasWrong = true;
            }
            return result
        }

        function originHandleSelectionResult(index, result){
            result = currQuestIdx == index
            if(result){
                correctCount++
                updateTimer()   //update timer before update score
                if(wasWrong){
                    wasWrongHandleSelection(index)
                }else{
                    updateAnsHistory(availableChoices[index], result)
                    setUpTheNewQuestion()
                }
            }else{
                updateAnsHistory(availableChoices[index], result)
                if(!wasWrong){
                    updateAnsHistory(availableChoices[currQuestIdx], result)
                }
                speechBinding.playSpeech(availableChoices[index].speech);
                wasWrong = true;
            }
            updateScore(result)            
            return result
        }

        function wasWrongHandleSelection(index){
            delayUpdateQuestion.start();
            deckMedia.speechClicked(availableChoices[index].speech);
        }

        function handleSelection(index){
            var result
            switch (Consts.directMatchMode){
            case Value.halfWordsID: result = halfHandleSelectionResult(index, result); break;
            case Value.twiceQuesID: result = twiceHandleSelectionResult(index, result); break;
            case Value.originalID: result = originHandleSelectionResult(index, result); break;
            }
            return result
        }

        function updateAnsHistory(card, result){
            Algor.updateAnsHistory(card, result)
            updateCardToDataBase(card)
        }

        function updateCardWithUserReply(card, result, ansTime){
            Algor.updateAnsHistory(card, result)
            var easiness = judgeEasiness(card, ansTime )

//            switch(easiness){ //Print log
//            case Algor.idAgain: console.log("Again"); break;
//            case Algor.idHard: console.log("Hard"); break;
//            case Algor.idGood: console.log("Good"); break;
//            case Algor.idEasy: console.log("Easy"); break;
//            }

            var consumeNewCard = Algor.updateStudyInfoWithUserReply(card, easiness)
            updateCardToDataBase(card)
            if(consumeNewCard){
                studiedNew++
                UserSettings.newCardsLeftToday = Math.max(0, UserSettings.newCardsLeftToday-1)
//                console.log("newCardsLeftToday", UserSettings.newCardsLeftToday)
            }else{
                studiedReview++
            }

        }

        function ansTooSlow(ansTime){
            if((Consts.directMatchMode == Value.twiceQuesID && ansTime > Consts.twiceQstSlow) ||
               (Consts.directMatchMode == Value.halfWordsID && ansTime > Consts.halfWordSlow) ){
                return true
            }else
                return false

        }

        function judgeEasiness(card, ansTime){
            var historyStr = card.ansHistory.toString(2)

            if(historyStr.substr(-1, 1) == "1"){// start idx = -1 => start idx = length -1 (= last bit)
                console.log(card.word, "AnsTime:", ansTime)
                if(ansTooSlow(ansTime)){
//                    console.log("slow")
                    return Algor.idHard
                }else if(!ansTooSlow(ansTime)){
//                    console.log("fast")
                    //Never wrong && answer more than once before
                    if(historyStr.indexOf("0") == -1 && historyStr.length > 2){
//                        console.log("easy")
                        return Algor.idEasy
                    }
                }else{
//                    console.log("normal speed")
                }

                if(historyStr.substr(-5, 5) == "11111" && historyStr.length > 5){
                    return Algor.idEasy //5 correct in a row
                }else if(historyStr.substr(-3, 3) == "111" && historyStr.length > 3){
                    return Algor.idGood //3 correct in a row
                }else{
                    return Algor.idHard
                }
            }else{
                return Algor.idAgain
            }
        }

        function dontKnowAnswer(){
            wasWrong = true
            speechBinding.playSpeech(availableChoices[currQuestIdx].speech)
            switch (Consts.directMatchMode){
            case Value.halfWordsID:
                updateCardWithUserReply(availableChoices[currQuestIdx], false, timeDuration - timeThisQuestStart);
                break;
            case Value.twiceQuesID: twiceModeDontKnowAns();break;
            case Value.originalID:
                updateScore(false)
                Algor.updateAnsHistory(availableChoices[currQuestIdx], false)
                return; break;
            default: console.assert("Wrong DirectMatchMode"); break;
            }
        }

        function twiceModeDontKnowAns(){
            if(newQuestion){
                twiceFirstCorrect = false;
            }else{
                if(!twiceFirstCorrect){
                    return
                }
            }
            updateCardWithUserReply(availableChoices[currQuestIdx], false, timeDuration - timeThisQuestStart);
        }

        function updateTimer(){
            oneRoundTimer += fullOneRoundTimer*Consts.lifeHeal
//            fullOneRoundTimer -= Consts.timeDiff

            if(oneRoundTimer > fullOneRoundTimer){
                oneRoundTimer = fullOneRoundTimer
            }

            lifeRatio = oneRoundTimer/fullOneRoundTimer

        }

        function updateScore(result){
            var healBonus = oneRoundTimer == fullOneRoundTimer
//            var amplify = Math.floor((Consts.initOneRoundTime - fullOneRoundTimer)/2000) + 1
            var amplify = Math.floor(correctCount/10) + //correct answer bonus
                    Math.floor((Consts.initOneRoundTime - fullOneRoundTimer)/2500) +1   //late game time bonus

            score += amplify * (result? 100 : -30)
            score += amplify * (healBonus? 100 : 0)
            score = score < 0 ? 0 : score
        }

        function updateCardToDataBase(card){
            card.lastStudy = (new Date()).valueOf()
            deckMedia.updateCardAsync(card, ["ef", "status", "learningStep", "interval",
                                        "due", "lastStudy", "lapseCount", "ansHistory"])
        }

        function settingUpdated(settings){
            Consts.init(settings)
            gameHost.numberOfChoice =  Consts.numberOfChoice
        }

        function resetGame(){
            score = 0
            timeDuration = 0
            studiedNew = 0
            studiedReview = 0
            correctCount = 0
            newQuestion = false
            wasWrong = false
            availableChoices = []
            fullOneRoundTimer = Consts.initOneRoundTime
            oneRoundTimer = fullOneRoundTimer
            stopGameTimer()
            Algor.setLearningSteps([1*Algor.min, 3*Algor.min, 6*Algor.min ])
            Algor.setNumberOfAheadDays(0)
        }

        function getHighScores(){
            return DbHandler.getHighScores(getDbIdentifier())
        }

        function getDbIdentifier(){
//            return [GeneralConsts.stringCardType[Consts.cardType], deckMedia.getDeck().split(".")[0]]
            return ["DirectMatch", Consts.cardType, deckMedia.getDeckID()] /*Do not use qsTr as DB key*/
        }

        function getHeaderInfoEements() {
            if(Consts.directMatchMode == Value.originalID){
                return [{infoTitle: GeneralConsts.txtGameQuestionPool,
                            information: GeneralConsts.stringCardType[Consts.cardType] },
                        {infoTitle: GeneralConsts.deck, information: deckMedia.getDeck().split(".")[0] },
                        {infoTitle: GeneralConsts.txtScore, information: score.toString() }]
            }else{
                return [{infoTitle: GeneralConsts.deck,
                            information: deckMedia.getDeck().split(".")[0] },
                        {infoTitle: "", information: ""},
                        {infoTitle: GeneralConsts.studied, information: studiedNew.toString()},
                        {infoTitle: GeneralConsts.reviewed, information: studiedReview.toString() }]
            }
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
            if(typeof(gameRecords[deckName].directMatch) == "undefined"){
                console.assert( typeof(gameRecords) != "undefined" && typeof(gameRecords[deckName]) != "undefined"
                               , "gameRecords should be initialized already" )
                gameRecords[deckName].directMatch = {gameMode: 0, halfWord: 0, twiceQuestions: 0}
            }

            switch(Consts.directMatchMode){
            case Value.originalID:
                gameRecords[deckName].directMatch.gameMode++
                break;
            case Value.halfWordsID:
                gameRecords[deckName].directMatch.halfWord++
                break;
            case Value.twiceQuesID:
                gameRecords[deckName].directMatch.twiceQuestions++
                break;
            default:
                console.assert(false, "Should be one of above modes")
            }

            appSettings.writeSetting(AppKeys.gameRecords, JSON.stringify(gameRecords))
        }

        function pullInScheduleAndResumeGame(){
            UserSettings.newCardsLeftToday = Algor.newCardsPerDay
            deckMedia.pullInPractice()
            Algor.setNumberOfAheadDays(0)
            setUpTheNewQuestion()
            durationTimer.start()
        }

    }
}
