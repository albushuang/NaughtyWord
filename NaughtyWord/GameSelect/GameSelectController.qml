import QtQuick 2.4
import QtQuick.Controls 1.3
import com.glovisdom.UserSettings 0.1
import com.glovisdom.AnkiDeck 0.1
import AppSettings 0.1
import "qrc:/NWUIControls"
import "qrc:/generalModel"
import "../deckDownloader"
import "../generalJS/objectCreate.js" as CompCreator
import "../generalJS/tutorialScript.js" as TutScript
import "GameSelectModel.js" as MODEL
import "../generalJS/generalConstants.js" as GeneralConsts
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/chooseDeck.js" as Choose


Item { id: gameSelectControl
    ListModel { id: gameList
        Component.onCompleted: {
            append({name: GeneralConsts.gameNameDirectMatch,
                    gameId: MODEL.fastHandID,   // Dont mix up translation and game ID
                    imageUrl: "qrc:/pic/NW_GamePage_Orange option.png",
                    diamond: true});
//            append({name: GeneralConsts.gameNameFlipMatch,
//                    gameId: MODEL.flipMatchID,
//                    imageUrl: "qrc:/pic/NW_GamePage_yellow option.png",
//                    diamond: true});
            append({name: GeneralConsts.gameNameInsanity,
                    gameId: MODEL.insanityID,
                    imageUrl: "qrc:/pic/NW_GamePage_yellow option.png",
                    diamond: true});
//            append({name: GeneralConsts.gameNameShuffle,
//                    gameId: MODEL.shuffleID,
//                    imageUrl: "qrc:/pic/NW_GamePage_Orange option.png",
//                    diamond: true});
            append({name: qsTr("Like glövisdom"),
                    gameId: MODEL.likeUsID,
                    imageUrl: "qrc:/pic/NW_GamePage_purple option.png",
                    diamond: false});
//            append({name: qsTr("TOEIC Battle"),
//                    gameId: MODEL. toeicBattleID,
//                    imageUrl: "qrc:/pic/NW_GamePage_purple option.png",
//                    diamond: true});
            append({name: GeneralConsts.gameNamePractice,
                    gameId: MODEL.ankiPracticeID,
                    imageUrl: "qrc:/pic/NW_GamePage_Exist option.png",
                    diamond: false });
            handleTutorialSelectDirectMatch()
        }        
    }

    DragMouseAndHint {id: dragHint
        target: gameSelectControl
        maxX: gameSelectControl.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "right"
    }

    GameSelectView {id: view
        anchors.fill: parent
        delegator: gameSelectControl
        gameListModel: gameList
        studyModel: studyInfoModel; modelDatas: studyInfoModel.modelDatas
        titleLv: studyInfoModel.titleLv
    }

    MouseArea{id: mouseExtensionForDrag
        width: parent.width*0.15; height: parent.height*11/12
        drag.axis: Drag.XAxis
    }

    AppSettings { id: appSettings }
    DeckSelectController{id: deckSelectController        
        onDlClicked: {
            createDeckDownloader()
        }
        onDeckChoosen: {
            studyInfoModel.updateStudyInfo(deck, deckSelectController.dirViewModel, !triggeredByUser)
            if(triggeredByUser) { delay.start() }
        }
        onUserChangeDeckWindow: { delay.stop() }
        Timer { id: delay
            onTriggered: deckSelectController.view.withDrawView()
            interval: 1700
        }
    }

    function handleBackToThisView(){
        if(stackView.currentItem == gameSelectControl){
            handleTutorialSelectDeck()
            studyInfoModel.updateStudyInfo(UserSettings.gameDeck, deckSelectController.dirViewModel, true)
        }
    }

    StudyInfoModel{id: studyInfoModel
        appSettings: appSettings
    }



    function clickOnCell(gameId) {
        var url
        var gameProperty = {state: "in-game"}
        switch(gameId){
        case MODEL.fastHandID:
            url = "qrc:/directMatchGame/DirectMatchGameViewController.qml"
            stopSelectDirectMatchTutorial()
            break;
        case MODEL.flipMatchID:
            url = "qrc:/GameFlipMatch/FlipMatchGameViewController.qml"
            break;
        case MODEL.insanityID:
            url = "qrc:/GameInsanity/InsanityViewController.qml"
            break;
        case MODEL.shuffleID:
            url = "qrc:/WordShuffle/WordShuffleViewController.qml";
            break;
        case MODEL.ankiPracticeID:
            url = "qrc:/GamePractice/LingoPracticeViewController.qml";
            break;
        case MODEL.likeUsID:
            return own.watchVideo()
//        case MODEL.toeicBattleID:
//            url = "qrc:/GameTOEICBattle/TOEICBattleViewController.qml";
//            gameProperty = {}
//            break;
        default:
            return
        }
        stackView.vtSwitchControl(url, gameProperty, false, false, true)
    }

    QtObject { id: own
        function watchVideo() {
            CompCreator.instantComponent(gameSelectControl, "qrc:/GameTOEICBattle/GrandPa.qml",
                                                { width: view.width*0.618,
                                                  adMob: stackView.adMob,
                                                  deleteLater: deleteLater })
        }
        function deleteLater(obj) {
            waitForGP.obj = obj
            waitForGP.start()
        }
    }
    Timer { id: waitForGP
        property var obj
        interval: 100
        onTriggered: { obj.destroy() }
    }

    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property variant tutArrayInThisQML: [UserSettings.tutSelectDirectMatch, UserSettings.tutSelectDeck ]
    property bool hasTutorial: false

    function handleTutorialCompComplete(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked);
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
        }
    }

    function handleTutorialSelectDirectMatch(){
        if(!UserSettings.tutSelectDirectMatch){
            tutorial.tutorialKey = TutScript.tutSelectDirectMatch
            view.gamesView.currentIndex = 0
            tutorial.focusItem = view.gamesView.currentItem
            tutorial.start(600)
        }
    }

    function handleTutorialSelectDeck(){
        if(!UserSettings.tutSelectDeck && UserSettings.tutSelectDirectMatch){
            deckSelectController.view.deckArrowClicked.connect(stopSelectDeckTutorial)
            tutorial.tutorialKey = TutScript.tutSelectDeck
            tutorial.focusItem = deckSelectController.view.arrow
            tutorial.start(600)
        }
    }

    function stopSelectDirectMatchTutorial(){
        try {
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutSelectDirectMatch)){
                tutorial.stop()
                UserSettings.tutSelectDirectMatch = true                
            }
        } catch (err) {
            console.error("stop tutorial error:", err)
            UserSettings.tutSelectDirectMatch = true
            if(tutorial != null) { tutorial.destroy() }
        }

    }

    function stopSelectDeckTutorial(){
        try {
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutSelectDeck)){
                deckSelectController.view.deckArrowClicked.disconnect(stopSelectDeckTutorial)
                tutorial.stop()
                UserSettings.tutSelectDeck = true
            }
        } catch (err) {
            console.error("stop tutorial error:", err)
            UserSettings.tutSelectDeck = true
            if(tutorial != null) { tutorial.destroy() }
        }
    }


    function foggyAreaClicked(){    //Do nothing in this case
    }

    Component.onCompleted: {
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                CompCreator.createComponent(gameSelectControl, tutorialQmlUrl,
                                        {width: gameSelectControl.width, height: gameSelectControl.height},
                                            handleTutorialCompComplete)
                break;
            }
        }
        stackView.onCurrentItemChanged.connect(handleBackToThisView)
        dragHint.setExtensionMouse(mouseExtensionForDrag)        
    }

    Component.onDestruction: {
        stackView.onCurrentItemChanged.disconnect(handleBackToThisView)
        if(tutorial!=null) { tutorial.destroy() }
    }

    property string deckDownloaderQmlUrl:"../deckDownloader/DeckDownloaderController.qml"
    property DeckDownloaderController deckDownloader

    function createDeckDownloader(){
        CompCreator.createComponent(gameSelectControl, deckDownloaderQmlUrl,{},
                                    deckDownloaderCreateComplete)
    }
    function deckDownloaderCreateComplete(result, objId, qmlName){
        if(result && qmlName == deckDownloaderQmlUrl){
            deckDownloader = objId
            deckDownloader.popupThisView()
            deckDownloader.Component.onDestruction.connect(deckSelectController.view.withDrawView)
            deckDownloader.Component.onDestruction.connect(deckSelectController.handleTutorialSelectOtherDeck)
        }
    }

}


