import QtQuick 2.0
import com.glovisdom.AnkiDeck 0.1
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import "ModelSettingsInLingoPractice.js" as Settings
import "../generalModel"
import "../generalJS/appsettingKeys.js" as AppKeys
import "SuperMemoAlgorithm.js" as Algor
import "../generalJS/chooseDeck.js" as Choose
import "qrc:/NWUIControls"

Item{
    signal practicingOver()
    signal lockFound(int unlocked, int locked, string deckName)
    property alias currCard: practiceHost.currCard  
    property alias newCardsLen: practiceHost.newCardsLen
    property alias learnCardsLen: practiceHost.learnCardsLen
    property alias reviewCardsLen: practiceHost.reviewCardsLen

    signal lingoPracticeSettingsReady(variant settings)
    function speechClicked(id){
        return practiceHost.deckMedia.speechClicked(id)
    }

    function getPicture() {
        return practiceHost.deckMedia.getRootPath() + currCard.image
    }

    function startPracticing(){
        return practiceHost.startPracticing()
    }

    function userClicks(easiness){
        return practiceHost.userClicks(easiness)
    }

    function pullInPractice(){
        return practiceHost.pullInPractice()
    }

    function checkNumOfCards(){
        return practiceHost.checkNumOfCards()
    }

    function practiceOver(){
        return practiceHost.practiceOver()
    }

    function scheduleAleadyCompeleted(){
        return practiceHost.scheduleAleadyCompeleted()
    }

    Item {
        id: practiceHost
        property int score: 0

        property variant currCard
        property variant newCards: []
        property variant learningCards: []
        property variant reviewCards: []
        property variant allCards: []   //For release purpose
        property var deckMedia

        property int newCardsLen: newCards.length
        property int learnCardsLen: learningCards.length
        property int reviewCardsLen: reviewCards.length
        property int unlocked:99999

        property int mode: 0

        LingoPracticeSettings{id: lingoPracticeSettings
            Component.onCompleted: {
                Settings.init(lingoPracticeSettings)
                lingoPracticeSettingsReady(lingoPracticeSettings)
            }
        }

        AppSettings { id: appSettings}
        BrowseAllow { id: browseAllow }
        Component.onCompleted: {
            deckMedia = Choose.createMedia(practiceHost,
                                           appSettings.readSetting(AppKeys.pathInSettings),
                                           { deck: UserSettings.gameDeck, soundON: UserSettings.soundAllON })
            browseAllow.dm = deckMedia
            unlocked = browseAllow.getUnlockedNumber()
            if(unlocked != -1) {
                var locked = deckMedia.getRowCounts()-unlocked
                if(locked>=0) { lockFound(unlocked, locked, UserSettings.gameDeck) }
            } else { unlocked = 99999 }
        }

        function startPracticing(){
            Algor.setLearningSteps([1.5*Algor.min, 8*Algor.min])
            Algor.setNumberOfAheadDays(0)
            fillCardsForThisPractice()
            return setupNextQuestion()
        }

        function fillCardsForThisPractice(cards){
            var newCardNum = Math.min(Settings.numberOfNewCardInOnePractice, UserSettings.newCardsLeftToday)
            newCards = deckMedia.fetchCards(newCardNum,
                            AnkiDeck.StatusNew|AnkiDeck.RowRange, AnkiDeck.Random, "", 0, 0, unlocked)
            learningCards = deckMedia.fetchCards(Settings.numberOfLearningCardInOnePractice,
                            AnkiDeck.StatusLearning|AnkiDeck.RowRange, AnkiDeck.ASC, "due", 0, 0, unlocked)
            reviewCards = deckMedia.fetchCards(Settings.numberOfReviewCardInOnePractice,
                            AnkiDeck.StatusReviewDueToday|AnkiDeck.RowRange, AnkiDeck.ASC, "due", 0, 0, unlocked)
            allCards = newCards.concat(learningCards, reviewCards)
        }

        /* the priority of dealing card is: 1."due learning card" > 2."new card" > 3."review card" > 4."undue learning card"*/
        function setupNextQuestion(){

            if (setQuestionAsLearningCard(true)){

            }else if(setQuestionAsNewCard()){

            }else if(setQuestionAsReviewCard()){

            }else if(setQuestionAsLearningCard(false)){

            }else{
                returnCards()
                practicingOver()
                return false
            }
            var today = new Date()
            currCard.lastStudy = today.valueOf()
            return true
        }

        function setQuestionAsLearningCard(checkDue){
            if(learningCards.length == 0){
                return false
            }else if (checkDue){
                var now = new Date()
                for (var i = 0; i < learningCards.length; i++){
                    if ((now.valueOf() - learningCards[i].due) >= 0){
                        /*now we just pick the first due card in the array（queue).
                        Maybe we need to choose a card randomly among all due cards*/
                        currCard = learningCards[i]
                        return true
                    }
                }
                return false
            }else{
                currCard = learningCards[0]
                for(var i = 1; i < learningCards.length; i++){
                    if (learningCards[i].due < currCard.due){
                        currCard = learningCards[i]
                    }
                }
                return true
            }

        }

        function setQuestionAsNewCard(){
            if(newCards.length == 0){
                return false
            }else{
                currCard = newCards[0]
                return true
            }
        }

        function setQuestionAsReviewCard(){
            if(reviewCards.length == 0){
                return false
            }else{
                currCard = reviewCards[0]
                return true
            }
        }

        function userClicks(easiness){
            var prevStatus = currCard.status
            Algor.updateStudyInfoWithUserReply(currCard, easiness)
            var countAsAnswerCorrect = (easiness == Algor.idEasy || easiness == Algor.idGood)
            Algor.updateAnsHistory(currCard, countAsAnswerCorrect)
            if(prevStatus != currCard.status || prevStatus == Algor.idReview){
                switch(prevStatus){
                case Algor.idNew:
                    UserSettings.newCardsLeftToday = Math.max(0, UserSettings.newCardsLeftToday-1)
                    removeCardById(currCard.id, newCards)
                    break
                case Algor.idLearning:
                    removeCardById(currCard.id, learningCards)
                    break
                case Algor.idReview:
                     removeCardById(currCard.id, reviewCards)
                    break
                }
                if(currCard.status == Algor.idLearning){ learningCards.push(currCard)}
            }

            updateCardToDataBase(currCard)
            setupNextQuestion()

            newCardsLen = newCards.length
            learnCardsLen = learningCards.length
            reviewCardsLen = reviewCards.length
        }

        function removeCardById(id, fromQueue){
            for (var i = 0; i < fromQueue.length; i++){
                if (fromQueue[i].id == id){
                    fromQueue.splice(i,1)
                    return true
                }
            }
            console.assert(false,"It's impossible that we cannot find currCard in queue", id)
        }

        function updateCardToDataBase(card){
            deckMedia.updateCardAsync(card, ["ef", "status", "learningStep", "interval", "due",
                                        "lastStudy", "lapseCount", "ansHistory"])
        }

        function returnCards(){
            for(var i = 0; i < allCards.length; i++){
                deckMedia.releaseCard(allCards[i])
            }
        }

        function checkNumOfCards(){
            var numOfCards = deckMedia.getRowCounts()
            var warningLog
            if(numOfCards == 0){
                warningLog = qsTr("There is no card in this deck.") ;
                return {
                    value: false, log: warningLog
                }
            }
            return{
                value: true, log:""
            }
        }

        function practiceOver(){
            var log = qsTr("Congratulation! You've already compeleted today's schedule.")
            return {log: log, value: true}
        }

        function scheduleAleadyCompeleted(){
            var log = qsTr("You've already compeleted today's schedule. Do you want to do advance review?")
            return {log: log, value: true}
        }

        function pullInPractice(){
            UserSettings.newCardsLeftToday = Algor.newCardsPerDay
            deckMedia.pullInPractice()
        }

//        function randomMultipleCards(originalCards, numOfRan){
//            var cards = originalCards.slice()
//            var subCards = []
//            numOfRan = cards.length >= numOfRan ? numOfRan : cards.length
//            for(var i = 0; i < numOfRan; i++){
//                var idx = Math.floor((Math.random() * cards.length))
//                subCards.push(cards[idx])
//                cards.splice(idx,1)
//            }
//            return subCards
//        }


    }

}
