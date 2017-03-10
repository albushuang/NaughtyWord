var choiceWidth = 80
var choiceHeight = 0
var choiceSpacing = 10

var questionLeftMargin = 33*hRatio
var questionTopMargin = 300*vRatio
var questionBottomMargin = 21*vRatio

var swipeValidDistance = 50


var disAgain = qsTr("No idea")  //"認不得"
var disHard = qsTr("Blurry")    //"印象模糊"
var disGood = qsTr("Good")  //"還算記得"
var disEasy = qsTr("Very easy")  //"很簡單"

if(Qt.platform.os === "windows" || Qt.platform.os === "osx" || Qt.platform.os === "linux" || Qt.platform.os === "unix"){
    choiceHeight = 60
    questionBottomMargin = 15
}
