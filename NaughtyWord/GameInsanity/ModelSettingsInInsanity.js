.pragma library
.import "settingValues.js" as Value
.import "../generalJS/generalConstants.js" as GeneralConsts

var gameMode
var numOfHardQstToRand = 5
var numberOfChoice

var initVelocityScale
var sec = 1000
var accelerateScale
var objectUnitSizeRatio = 1/12
var mainRoleWScale = 1.5
var mainRoleHScale = 1.5
var obsWScale = [1, 1.5, 1, 1.5]
var obsHScale = [1, 1.5, 1.5, 1]
var choiceWScale
var choiceHScale
var obsInitPositionX = [0, 1, 0, 1] // range: 0~1.  0 means origin point. 1 means displayScreen.width - obstacle.width
var obsInitPositionY = [0, 0, 1, 1]
var mainRuleBufferDistance = 0.8
var choiceBufferDistance
var newPowerUpHintTime = 0//2000
var endPowerUpHintTime = 2000
var originMainRoleScale = 1
var smallerMainRoleScale = 0.6
var smallerTimeLimit = 5000
var smallerTimeCoolDown = 5000

var coinRatioWithLvMeduim = 0.2
var maxCoinsWithLvMedium = 2000
var coinRatioWithLvEasy = 0.1
var maxCoinsWithLvEasy = 1500

var powerUpTimerRandomRange = [5*sec, 6*sec]
var powerUps = [];  //powerUp information with current level
var powerUpTables =
               [{type: Value.teacher, timer:     [ 4*sec, 6*sec, 8*sec, 9*sec, 10*sec, 12*sec],
                 probability: 20, effects:   []},
                {type: Value.smart, timer:       [ 4*sec, 6*sec, 8*sec, 9*sec, 10*sec, 12*sec],
                 probability: 20, effects:   []},
                {type: Value.invisible, timer:   [ 3*sec, 5*sec, 6*sec, 7*sec, 8*sec, 10*sec],
                 probability: 15, effects:   []},
                {type: Value.gravity, timer:     [ 0*sec, 0*sec, 0*sec, 0*sec, 0*sec, 0*sec],
                 probability: 10, effects:   [ 0.95,  0.9,   0.875, 0.85,  0.825, 0.8]},
                {type: Value.shrinker, timer:    [ 8*sec, 10*sec, 10*sec, 12*sec, 15*sec, 15*sec],
                 probability: 20, effects:   [ 0.85,  0.85,   0.75,   0.75,   0.75,   0.6]},
                {type: Value.redBull, timer:     [ 3*sec, 5*sec, 5*sec, 7*sec, 7*sec, 10*sec],
                 probability: 15, effects:   [ 1.5,   1.5,   1.75,  1.75,  2,     2]}
                ]

//Call init after insanitySettings is ready
function init(settings){
    gameMode = settings.gameType
    numberOfChoice = (gameMode == Value.image) ? 2 : 3
    initVelocityScale = getInitVel(settings)
    accelerateScale = getAccScale(settings)
    choiceWScale = gameMode == Value.image ? 2.5 : 0.7
    choiceHScale = gameMode == Value.image ? 2.5 : 0.7
    choiceBufferDistance = gameMode == Value.image ? 0.05 : 5
    initPowerUpForItsLevel(settings)
}

function getInitVel(settings){
    return 2
//    switch(settings.easiness){
//    case GeneralConsts.gameHardID: return 3
//    case GeneralConsts.gameMediumID: return 2
//    case GeneralConsts.gameEasyID: return 1
//    }
}

function getAccScale(settings){//return how many second to double the initial speed
    return 40
//    switch(settings.easiness){
//    case GeneralConsts.gameHardID: return 40
//    case GeneralConsts.gameMediumID: return 40
//    case GeneralConsts.gameEasyID: return 40
//    }
}

function initPowerUpForItsLevel(settings){
    for(var i = 0; i < powerUpTables.length; i++){
        var level = settings[powerUpTables[i].type];
        powerUps.push({type: powerUpTables[i].type,
                       timer: powerUpTables[i].timer[level],
                       effect: powerUpTables[i].effects[level],
                       probability: powerUpTables[i].probability})
    }
    return true
}
