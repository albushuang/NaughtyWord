.pragma library

//gameType
//questionType
var stringQuestionType = [qsTr("Word"), qsTr("Image"), qsTr("Definition"), qsTr("Pronunciation")]
var txtQuestionType = qsTr("Question Type")
var questionWordsID = 0
var questionImagesID = 1
var questionMeaningsID = 2
var questionPronounceID = 3

//answerType
var stringAnswerType = [qsTr("Words"), qsTr("Images"), qsTr("Definitions")]
var txtAnswerType = qsTr("Answer Type")
var answerWordsID = questionWordsID
var answerImagesID = questionImagesID
var answerMeaningsID = questionMeaningsID

//DirectMatchMode
var originalID = 0
var halfWordsID = 1
var twiceQuesID = 2

//TutorialFilter
var tutQuesClickableThreshold = 3


var evtCodeGameStatus = 0
var evtCodeQuestionSet = 1

// key of event = game status
var keyScore = "0"
var keyResult = "1"
var keyTime = "2"

// key of event = question set
var keyQuestion = "0"
var keyAnswers1 = "1"
var keyAnswers2 = "2"
var keyAnswers3 = "3"
var keyAnswers4 = "4"

