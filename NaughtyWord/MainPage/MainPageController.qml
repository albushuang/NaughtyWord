import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import com.glovisdom.NWPleaseWait 0.1
import com.glovisdom.UserSettings 0.1
import "../generalJS/objectCreate.js" as CompCreator
import "../generalJS/tutorialScript.js" as TutScript
import "qrc:/../UIControls"
import "../NWUIControls"

Item { id: mainControl
    property var userTerms
    property var checker
    MainPageView { id: mainPage
        anchors.fill: parent
        delegator: mainControl
    }

    function leg1Clicked(mouse) {
        if(hasTutorial && tutorial.isOnGoing(TutScript.tutSelectGameSection)){
            tutorial.stop()
            UserSettings.tutSelectGameSection = true
        }

        stackView.vtSwitchControl("qrc:/GameSelect/GameSelectController.qml", {}, false, false, true);
    }
    function leg2Clicked(){
        stackView.vtSwitchControl( "qrc:/DictLookup/DictLookupController.qml",{}, false, false, true);
    }

    function leg3Clicked(mouse) {
        stackView.vtSwitchControl("qrc:/MainPage/Settings.qml", {}, false, false, true);
    }
    function about() {
        stackView.vtSwitchControl("qrc:/MainPage/About.qml", {}, false, false, true);
    }

//    function callEngineeringMode(){
//        stackView.vtSwitchControl("qrc:/MainPage/EngineeringSetting.qml", {}, false, false, true);
//    }

    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property variant tutArrayInThisQML: [UserSettings.tutSelectGameSection ]
    property bool hasTutorial: false

    function handleTutorialSelectGameSection(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked);
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
            if(!UserSettings.tutSelectGameSection){
                tutorial.tutorialKey = TutScript.tutSelectGameSection
                tutorial.focusItem = mainPage.gameArea
                tutorial.start(600)
            }
        }
    }

    function foggyAreaClicked(){    //Do nothing in this case
    }

    Component.onCompleted: {
        if(UserSettings.termsAccepted == false || UserSettings.thisAppVersion > UserSettings.lastAppVersion) {
            userTerms = CompCreator.instantComponent(mainControl, "qrc:/MainPage/ServiceTerms.qml", {})
            userTerms.deleteLater = own.deleteLater;
        //} else if (UserSettings.decksBuilt == false) {
        } else if (true) {
            own.checkingDecks()
        } else {
            own.prepareTutor()
        }
    }
    Component.onDestruction: {
        if(typeof(own.tutor)!="undefined") { own.tutor.destroy() }
    }

    QtObject { id: own
        property var tutor
        function deleteLater(obj) {
            later.toDo = goOn
            later.interval=1
            later.start()
        }
        function goOn() {
            userTerms.destroy();
            checkingDecks()
        }

        function deleteLater2(obj) {
            later.toDo = goOn2
            later.interval=1
            later.start()
        }
        function goOn2() {
            checker.destroy()
            UserSettings.decksBuilt = true
            prepareTutor()
        }
        function prepareTutor() {
            for(var i = 0; i < tutArrayInThisQML.length; i++){
                if(!tutArrayInThisQML[i]){
                    tutor = CompCreator.createComponent(mainControl, tutorialQmlUrl,
                                            {width: mainControl.width, height: mainControl.height},
                                                handleTutorialSelectGameSection)
                    break;
                }
            }
        }
        function checkingDecks() {
            var w = stackView.width==0 ? Screen.width : stackView.width
            var h = stackView.height==0 ? Screen.height : stackView.height
            checker = CompCreator.instantComponent(mainControl, "qrc:/MainPage/InitDecks.qml",
                        {width: w, height: h, callback: own.deleteLater2 })
            later.toDo = checker.start
            later.interval=1
            later.start()
        }
    }
    Timer { id: later
        property var toDo
        triggeredOnStart: false;
        interval: 1
        repeat: false
        onTriggered: { toDo() }
    }
}
