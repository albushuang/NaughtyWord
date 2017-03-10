pragma Singleton
import QtQuick 2.0
import Qt.labs.settings 1.0
import com.glovisdom.WordSpeaker 0.1
import "../generalJS/generalConstants.js" as GeneralConsts
import "../GamePractice/SuperMemoAlgorithm.js" as Algor
/*NOTICE!!!  You cannot create more than one instance at the same time.
For example, create one instance in MainPageView and create another instance in GameSetting.
Two instances at the same time will lead unexpected problem.*/

//        ~/Library/Application Support/NaughtyWord...
//        ~/Library/Caches/NaughtyWord...
//        ~/Library/Preferences/NaughtyWord...


Settings {
    category: "User"
    readonly property string lookup: "lookup.tst.sch.pro.lif.etm.tvl.kmrj"
    readonly property real thisAppVersion: 2.0
    readonly property string defaultDeck: "fruits.lif.kmrj"
    property real lastAppVersion: 0
    property bool termsAccepted: false
    property bool decksBuilt: false
    property int coins: 0
    property int gems: 0
    property string gameDeck: defaultDeck
    property string addDeck: lookup
    property string lastInputName: GeneralConsts.companyName
    property real musicVolume: 1
    property real soundEffectVolume: 1
    property int newCardsLeftToday: Algor.newCardsPerDay
    property date lastOpenDate: new Date()
    property int fontPointSize: 20
    property bool searchForCommercial: false
    property string uuid: generateUUID()
    property string title: ""
    property int allGold: 400


//GameDirectMatchTutorial
    property bool tutDirectQuesClickable: false

//GameInsanityTutorial
    property bool tutInsanityIntro: false
    property bool tutMoveEinstein: false
    property bool tutAnswerTheQuestion1: false
    //property bool tutAnswerTheQuestion2: false //Question1 and Question2 are buddled together
    property bool tutPowerUpIntro: false

//GameFlipMatchTutorial
    property bool tutFlipMatchIntro: false

//GamePracticeTutorial
    property bool tutHowToUseAnki1: false
    property bool tutHowToUseAnki2: false
    property bool tutHowToUseAnki3: false
    property bool tutHowToUseAnki4: false

//MainPage tutorial
    property bool tutSelectGameSection: false

//GameSelection tutorial
    property bool tutSelectDirectMatch: false
    property bool tutSelectDeck: false

//DeckSelection tutorial
    property bool tutClickMoreDecks: false
    property bool tutSelectOtherDeck: false

//Dictionary tutorial
    property bool tutUseAnotherKeyWord1: false
    //property bool tutUseAnotherKeyWord2: false    //1 & 2 are buddled together
    property bool tutUseDictionary: false
    property bool tutSaveWord: false

// DecksController tutorial
    property bool tutPressAndHold: false

//Reminder
    property bool dragToExitRemind: true
    property bool wordSavedRemind: true
    property string remindTypeDragToExit: "remindDragToExit"
    property string remindTypeWordSaved: "remindWordSaved"
    property string remindTypeNoImage: "remindNoImage"

//DirectLink
    property int directLink: 0
    property int autoDict: 0
    property int notesOnly: 0  // works with directLink

//Music and sound
    property bool musicON: true
    property bool soundAllON: true
    property bool soundGameON: true


// User usage records
    property int searchCount: 0
    property int useOtherKeyCount: 0
    property int addCardCount: 0
/*qml Settings to store array has unresolved bug. Use C++ setting https://bugreports.qt.io/browse/QTBUG-45316*/
//    property variant gameRecords: []


    function resetAllTutorial(){
        tutInsanityIntro = tutMoveEinstein = tutAnswerTheQuestion1 = tutPowerUpIntro =
        tutHowToUseAnki1 = tutHowToUseAnki2 = tutHowToUseAnki3 = tutHowToUseAnki4 =
        tutFlipMatchIntro = tutSelectGameSection = tutSelectDirectMatch = tutSelectDeck =
        tutUseAnotherKeyWord1 = tutUseDictionary =  tutSaveWord = tutPressAndHold = tutDirectQuesClickable =
        tutClickMoreDecks = tutSelectOtherDeck = false
    }

    function showAllReminderAgain(){
        dragToExitRemind = true
        wordSavedRemind = true
    }

    function defaultAddDeck() {
        addDeck = "lookup.lif.kmrj"
    }

    function generateUUID(){
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.round(Math.random()*16), v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        })
    }

    Component.onCompleted: {
        var now = new Date(), todayFourAM = (new Date()).setHours(4,0,0,0)
        if(lastOpenDate.valueOf() < todayFourAM.valueOf()){
            newCardsLeftToday = Algor.newCardsPerDay
        }
        lastOpenDate = now
        while(uuid.length > 36){
            uuid = generateUUID()   //For unknown reason, iPhone might have change o generate wron uuid
            console.log("UUID", uuid)   //Repeat generating until it is right
        }
    }
}

