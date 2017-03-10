.pragma library
function getScriptObj(key){
    for(var i = 0; i < wholeTable.length; i++){
        if(wholeTable[i].key == key){
            return wholeTable[i]
        }
    }
    console.assert(false, "WholeTable should contain the key:" + key)
}


//TODO 使用卡牌管理: 解釋刪除卡牌  解釋重新查詢
//TODO 字典管理: 解釋加卡牌/重新查詢/ 點圖放大可以用別的關鍵字查詢


//All tutorial keys
//var tutVeryBeginning = 0
var tutSelectGameSection = 1
var tutSelectDeck = 2
var tutSelectDirectMatch = 3
//var tutSelectAnkiPractice = 4
var tutHowToUseAnki1 = 5
var tutHowToUseAnki2 = 6
var tutHowToUseAnki3 = 7
var tutHowToUseAnki4 = 8
var tutUseDictionary = 9
var tutSaveWord = 10
var tutUseAnotherKeyWord1 = 11
var tutUseAnotherKeyWord2 = 12
//var tutSaveCard = 13
var tutInsanityIntro = 14
var tutMoveEinstein = 15
var tutAnswerTheQuestion1 = 16
var tutAnswerTheQuestion2 = 17   // Buddle to AnswerTheQuestion1. Doesn't need appSettings
var tutPowerUpIntro = 18
var tutFlipMatchIntro = 19
var tutPressAndHold = 20
var tutDirectQuesClickable = 21
var tutClickMoreDecks = 22
var tutSelectOtherDeck = 23

//這些圖片全部沒有版權，只是demo用
var wholeTable =
        [{
//             key : tutVeryBeginning,
//             imageSource: "qrc:/pic/tutorial.png",
//             //: original: 快來跟頑皮的\"單字\"一起\n調。皮。搗。單
//             guideText: qsTr("Come and Play with Naughty Words!!")
         },{
             key : tutSelectDeck,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("You can also select other decks for playing games.")
         },{
             key : tutSelectGameSection,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("First, let's play games!!")
         },{
//             key :tutSelectAnkiPractice,
//             imageSource: "qrc:/pic/tutorial.png",
//             guideText: qsTr("Want to get higher scores?? \nTry \"Practice Mode\" to get familiar with cards!")
         },{
             key :tutSelectDirectMatch,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Please choose first game.")
         },{
             key :tutHowToUseAnki1,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Click to show answer.")
         },{
             key :tutHowToUseAnki2,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Press and hold shows you the functions of dragging.")
         },{
             key :tutHowToUseAnki3,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Dragging in different directions,\ntells us your familiarity with the words.")
         },{
             key :tutHowToUseAnki4,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Great!!\nHard words will be asked more times, \nand you'll remember it!\n~This is how \"Practice Mode\" works! Isn't it easy?~\n")
         },{
             key :tutUseDictionary,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("When you consult a dictionary, you can browse and choose suitable image for the word.")
         },{
             key :tutSaveWord,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("When you find a suitable image, remember to add the card. And you can play games with the card.")
         },{
             key :tutUseAnotherKeyWord1,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Couldn't find suitable image?\nPlease click the image.")
         },{
             key :tutUseAnotherKeyWord2,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("You can try other key words to find suitable image.\n(Other language also works! For example: Chinese or Spanish.)")
         },{
//             key :tutSaveCard,
//             imageSource: "qrc:/pic/tutorial.png",
//             guideText: qsTr("Press the button above and save the card.\n Then this can be used in the games!")
         },{
             key :tutInsanityIntro,
//             imageSource: "qrc:/pic/tutorial_owl.png",
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Alien Octopus is our firend. \nPlease keep her away from aerolites.")
         },{
             key :tutMoveEinstein,
//             imageSource: "qrc:/pic/tutorial_owl.png",
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Touch the finger print. \nThen you can move Alien Octopus.")
         },{
             key :tutAnswerTheQuestion1,
//             imageSource: "qrc:/pic/tutorial_owl.png",
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Great!! \n You've passed the basic test.\nLet's search for more naughty words!")
         },{
             key :tutAnswerTheQuestion2,
//             imageSource: "qrc:/pic/tutorial_owl.png",
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Touch the fur ball of the correct answer to get score!!")
         },{
             key :tutPowerUpIntro,
//             imageSource: "qrc:/pic/tutorial_owl.png",
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Cosmic material can enhance her ability for a while and help you get higher score!!")
         },{
             key :tutFlipMatchIntro,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Memorize the position of cards within a few seconds. \nAnd try to match the images with the words.\nGood luck!!")
         },{
             key :tutPressAndHold,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Single Click: Browsing the deck\nPress and Hold: Settings menu")
         },{
             key :tutDirectQuesClickable,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("If you don't know this word, you can also click on question card. The card back will show you more information of the word.")
         },{
             key :tutClickMoreDecks,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Please click the button to download more decks")
         },{
             key :tutSelectOtherDeck,
             imageSource: "qrc:/pic/tutorial.png",
             guideText: qsTr("Now, you can select any other deck to play the game")
         }

        ]
