.pragma library

var companyName = "glövisdom"

var appName = qsTr("Naughty Word")
var deck = qsTr("Deck")

//Name of Games
var gameNameDirectMatch = qsTr("Fast Hand")
var gameNameFlipMatch = qsTr("FlipMatch")
var gameNameInsanity = qsTr("Insanity")
var gameNameShuffle = qsTr("WordShuffle")
var gameNamePractice = qsTr("Practice")


//Dialoue and Reminder Buttons
var txtConfirm = qsTr("OK")
var txtCancel = qsTr("Cancel")


// waringLog for insufficient cards
// %1 and %2 will be given by individual game host
var warnDeckLackCard = qsTr("There are only %1 cards in this deck. This game takes at least %2 cards.")
var warnPracticedTodayLackCard =  qsTr("You've selected \"%1\" as \"%3\". Please make sure you have practiced at least %2 cards in this deck today.")
var warnAllPracticedLackCard = qsTr("You've selected \"%1\" as \"%3\". Please make sure you have practiced at least %2 cards in this deck.")


// General game settings // Easiness
//: Game easiness
var stringGameEasiness = [qsTr("Hard"), qsTr("Medium"), qsTr("Easy")]
var gameHardID = 0
var gameMediumID = 1
var gameEasyID = 2

// General game settings // CardType
//: The question type to be issued
var stringCardType = [qsTr("All Word"), qsTr("Practiced Today"), qsTr("All Practiced")]
var gameAllWordID = 0
var gameTodayPracticedID = 1
var gameAllPracticedID =2

// General game settings // DealingType
//: The way to ask question
var stringDealingType = [qsTr("Random"), qsTr("Hard First")]
var gameRandomID = 0
var gamePracticeID = 1


//GeneralGameRadioBtnSettings
var txtGameMode = qsTr("Mode") // Replacing "Mode", "Type", "GameMode", "GameType"
var txtGameLevel = qsTr("Level") // Replacing "Level", "Easiness", "GameLevel", "GameEasiness"
var txtGameQuestionPool = qsTr("Question Pool")
var txtGameDeallingType = qsTr("Dealing Type")

//Elements frequently used in Games
var txtTime = qsTr("Time")
var txtScore = qsTr("Score")
var txtTotal = qsTr("Total")
var txtName = qsTr("Name")
var txtStart = qsTr("Start")
var txtSettings = qsTr("Settings")
var txtStore = qsTr("Store")

//Abbreviations for words too long (usullay for longer than 6 words)
//: translation should be no longer than 5 characters
var txtAbbrDefinition = qsTr("Def.")
//: translation should be no longer than 5 characters
var txtAbbrPronuciation = qsTr("Pron.")
//: translation should be no longer than 5 characters
var txtAbbrSynonym = qsTr("Syn.")
//: translation should be no longer than 5 characters
var txtAbbrDelete = qsTr("Del.")

//Learing Process
var studied = qsTr("Studied")
var reviewed = qsTr("Reviewed")

//Settings Value
var androidVolumeAdjust = 0.7

var timeBaseline = 1462982400000 //  2016/5/12 00:00:00. To save integer size to pass in network
