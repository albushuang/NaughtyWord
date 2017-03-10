.pragma library
.import com.glovisdom.AnkiDeck 0.1 as Anki

//Status
var idNew = 0
var idLearning = 1
var idReview = 2

//easiness
var idAgain = 0
var idHard = 1
var idGood = 2
var idEasy = 3

var second = 1000
var min = second * 60
var hour = min * 60
var day = hour * 24
var dueOfLearningSteps = [1.5*min, 8*min]  //[1.5, 8] minutes
var initIntervalForReview = [1*day, 4*day]  //First element is for "good". Second element is for "easy"
var initEF = 2.5
var adjustEF = [-0.2, -0.15, 0, 0.15] //Again: -0.2 Hard: -0.15  Good: 0 Easy: 0.15
var newCardsPerDay = 20
var numberOfAheadDays = 0

var numOfBitsInAnsHistory = 7
/*_____________________________Public functions_______________________________________*/
function setLearningSteps(stepLists){
    dueOfLearningSteps = stepLists
}

function setNumberOfAheadDays(days){
    numberOfAheadDays = days
}

function getQuestions(deckMedia, numberOfCards, newCardsLeftToday, acceptNotDueLearning){
    //Priority: Due learningCard > new > due reviewCard > not Due learningCard
    var filters = [Anki.AnkiDeck.StatusLearningDueNow, Anki.AnkiDeck.StatusNew,
            Anki.AnkiDeck.StatusReviewAheadDays, Anki.AnkiDeck.StatusLearning]
//    console.log("filters ", filters[0], filters[1], filters[2], filters[3])
    var orders = [Anki.AnkiDeck.ASC, Anki.AnkiDeck.Random, Anki.AnkiDeck.ASC, Anki.AnkiDeck.ASC]
    var orderTargets = ["due", "", "due", "due"]
    if(acceptNotDueLearning == false){
        filters.pop(); orders.pop(); orderTargets.pop();
    }

    var questions = []
//    console.log("newCardsLeftToday:", newCardsLeftToday)
//    console.log("numberOfAheadDays", numberOfAheadDays)
    for(var i = 0; i < filters.length && questions.length < numberOfCards; i++){

        if(filters[i] == Anki.AnkiDeck.StatusNew && newCardsLeftToday <= 0){
            continue;   //skip if learn enough newCards
        }

        var thisFetch = deckMedia.fetchCards(numberOfCards - questions.length,
                                             filters[i], orders[i], orderTargets[i], numberOfAheadDays)
        questions = questions.concat(thisFetch)
//        console.log("question length:", questions.length, "questions", questions)

        switch(filters[i]){ //Just print log for debug
//        case Anki.AnkiDeck.StatusLearningDueNow:
//            console.log("fetch ", thisFetch.length, " LearningDueNow cards")
//            break;
//        case Anki.AnkiDeck.StatusNew:
//            console.log("fetch ", thisFetch.length, " New cards")
//            break;
//        case Anki.AnkiDeck.StatusReviewAheadDays:
//            console.log("fetch ", thisFetch.length, " Review ahead" + numberOfAheadDays + " cards")
//            break;
//        case Anki.AnkiDeck.StatusLearning:
//            console.log("fetch ", thisFetch.length, " LearningNotDue cards")
//            break;
        }
    }
//    if(questions.length > 0){
//        var status = ["new", "learning", "review"]  //Just for debug log
//        console.log(questions[0].word, "status", status[questions[0].status], "step", questions[0].learningStep)
//    }else{
//        console.log("Finish today practice")
//    }

    return questions
}

function updateStudyInfoWithUserReply(card, easiness) {
    var consumeNewCard = false
    switch(card.status){
    case idNew:
//        console.log(card.word, "was new Card")
        updateCardForNewCard(card, easiness)
        consumeNewCard = true        
        break
    case idLearning:
//        console.log(card.word, "was leanrning card, step:", card.learningStep, " interval:", card.interval)
        updateCardForLearningCard(card, easiness)        
        break
    case idReview:
//        console.log(card.word, "was review card", " interval:", card.interval)
        updateCardForReviewCard(card, easiness)
        break
    }

    switch(card.status){
    case idLearning:
//        console.log(card.word, "is leanrning card, step:", card.learningStep, " interval:", card.interval)
        break
    case idReview:
//        console.log(card.word, "was review card", " interval:", card.interval)
        break
    }

    return consumeNewCard
}

function updateAnsHistory(card, result){
    //In SqLite 3, INT takes 1,2,4,8 bytes depends on magnitude (value). Make sure the value less than
    //2^7 so it will take only one byte. In this case, we have 6 bits to remember privous answers (the first
    //bit is used to represent bit start)

//    if(getBit(card.ansHistory, numOfBitsInAnsHistory-1) == 1){
    var binStr = card.ansHistory.toString(2)
    if(binStr.length >= numOfBitsInAnsHistory){
        //Only get last 5 answers. (the first bit was flag, the second bit is oldest answer we want to get rid of
        binStr = binStr.substr( binStr.length - (numOfBitsInAnsHistory - 2) , numOfBitsInAnsHistory - 2)
        binStr = "1" + binStr + result ? "1" : "0"
        card.ansHistory = parseInt(binStr)
    }else{
        card.ansHistory = card.ansHistory*2 + (result ? 1 : 0)
    }
//    console.log(card.word, " ansHistory", card.ansHistory.toString(2))
}

/*_____________________________Private functions_______________________________________*/
function updateCardForNewCard(card, easiness){

    switch(easiness){
    case idAgain:
    case idGood:
    case idHard:
        card.status = idLearning
        if(easiness == idAgain){
            card.learningStep = 0
        }else{
            card.learningStep = 1
        }
        card.interval = dueOfLearningSteps[card.learningStep]
        updateDueAndEF(card, 0)

        break;
    case idEasy:
        card.status = idReview
        card.interval = initIntervalForReview[1]
        updateDueAndEF(card, 0)
        card.ef = initEF    //updateDueAndEF pass diffEF. We want to set exact initEF not diff
        break;
    }

}

function updateCardForLearningCard(card, easiness){
    switch(easiness){
    case idAgain:
        card.learningStep = 0
        card.interval = dueOfLearningSteps[card.learningStep]
        updateDueAndEF(card, adjustEF[easiness])
        break
    case idGood:
    case idEasy:
    case idHard:
        if((easiness == idHard || easiness == idGood) &&
           (card.learningStep + 1) < dueOfLearningSteps.length){
            card.learningStep += 1
            card.interval = dueOfLearningSteps[card.learningStep]
            updateDueAndEF(card, 0)
        }else{
            card.status = idReview
            if(easiness == idHard || easiness == idGood){
                card.interval = initIntervalForReview[0]
            }else{
                card.interval = initIntervalForReview[1]
            }

            updateDueAndEF(card, adjustEF[easiness])
            if(card.lapseCount == 0){
                card.ef = initEF
            }
        }
    }
}

function updateCardForReviewCard(card, easiness){
    switch(easiness){
    case idAgain:
        card.status = idLearning
        card.learningStep = 1
        card.interval = dueOfLearningSteps[card.learningStep]
//        console.log(card.word, card.word, "card.interval", card.interval)
        card.lapseCount++
        break
    case idHard:
        card.interval *= 1.2
        break
    case idGood:
        card.interval *= card.ef
        break
    case idEasy:
        card.interval *= card.ef * 1.2
        break
    }

    updateDueAndEF(card, adjustEF[easiness])
}

function updateDueAndEF(card, diffEF){
    var newDue = new Date()
    newDue.setMilliseconds(newDue.getMilliseconds() + card.interval)
    card.due = newDue.valueOf()
    card.ef += diffEF
    card.ef = Math.max(1.3, card.ef)
}

//function getBit(intValue, index){   //index is the bit count from the right
//    var binStr = intValue.toString(2)
//    return parseInt(binStr.substr(-1 - index, 1))   //charAt cannot give nagetive index
//}

//function orBit(intValue1, intValue2){
//    var binStr1 = intValue1.toString(2)
//    var binStr2 = intValue2.toString(2)
//    var orStr = ""

//    var index = 0
//    while(index < binStr1.length || index < binStr2.length){
//        if(binStr1.substr(-1 - index, 1) == "1" || binStr2.substr(-1 - index, 1) == "1"){
//            orStr = "1" + orStr
//        }else{
//            orStr = "0" + orStr
//        }
//        index++
//    }

//    return parseInt(orStr, 2)
//}

//function andBit(intValue1, intValue2){
//    var binStr1 = intValue1.toString(2)
//    var binStr2 = intValue2.toString(2)
//    var andStr = ""

//    var index = 0
//    while(index < binStr1.length || index < binStr2.length){
//        if(binStr1.substr(-1 - index, 1) == "1" && binStr2.substr(-1 - index, 1) == "1"){
//            orStr = "1" + orStr
//        }else{
//            orStr = "0" + orStr
//        }
//        index++
//    }

//    return parseInt(orStr, 2)
//}
