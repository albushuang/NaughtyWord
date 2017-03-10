.pragma library
.import "settingValues.js" as Value
var sizeOfDirectMatchGame = [3,2]  //Put larger number in index = 0
var numberOfChoice = sizeOfDirectMatchGame[0] * sizeOfDirectMatchGame[1]

//var timeForOneRound = 60 * 1000
var second = 1000
var initOneRoundTime
var timeDiff = 0.2 * second
var lifeHeal = 0.3
var gameSecond = 20
var practiceSecond = 0.3*second
var shortPenaltyTime = second //For each mistake, use shortPenaltyTime
var longPenaltyTime = 1.8*second  //When changing new question, use longPenaltyTime

var twiceQstFast = 5.5*second
var twiceQstSlow = 9*second
var halfWordFast = 4.5*second
var halfWordSlow = 7.5*second

var cardType
var dealingType

var directMatchMode = Value.originalID

var correctPunishColor = "#ffff4d"
var wrongPunishColor = "gray"

var numOfHardQstToRand = 5
var randomAllProbability = 0.2

var maxLines = 3

//pr stands for probability
var prDefinitionWord = 0.15
var prImageWord = 0.15
var prWordImage = 0.35
var prWordDefinition = 1 - prDefinitionWord - prImageWord - prWordImage

function init(settings){        
    cardType = settings.cardType
}

function initTimer(mode){
    if(mode == Value.originalID){
        initOneRoundTime = gameSecond * 1000
    }else{
        initOneRoundTime = practiceSecond * 1000
    }
}
