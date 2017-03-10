import QtQuick 2.0
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "../DirectoryView"
import "../generalModel"
import "../NWUIControls"
import "qrc:/NWDialog"
import "../controllers"
import "qrc:/../UIControls"
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/deckCategoryConsts.js" as CateConst
import "../generalJS/objectCreate.js" as Create
import "../generalJS/tutorialScript.js" as TutScript

Item { id: root;

    property int category: CateConst.idTest

    DragMouseAndHint {
        target: root
        maxX: root.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
    }

    AppSettings{id: appSettings}

    property variant bgImgList: [
        "decksView_test.png", "decksView_school.png", "decksView_profession.png",
        "decksView_life.png", "decksView_entertainment.png", "decksView_travel.png"
    ]

    DecksView{ id: mainView
        bgImg: bgImgList[root.category]
        folderModel: thisModel.dirViewModel.dirModel
        categoryModel: thisModel.categoryModel
        onCaregoryIconClicked: {thisModel.handleMainIconClicked()}
        onCategoryClicked: {thisModel.categoryModel.updateIsFilterOn(index, isOn)}
        onCategorySelectionEnd: {thisModel.reassignCategory()}
        onBackClicked: {
            stackView.pop()
        }
        onDeckPressAndHold: {
            thisModel.handlePropertyClicked(index)
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutPressAndHold)){
                stopTutorial("tutPressAndHold")
            }
        }

        onDeckClicked: {
            stackView.vtSwitchControl("qrc:/deckManagement/OneDeckViewController.qml", {deck: fileName},
                                         false, false, true);
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutPressAndHold)){
                stopTutorial("tutPressAndHold")
            }
        }
        onAutoDictClicked: {
            console.log(fileName, index)
            var lookup = stackView.switchControl("qrc:/deckManagement/AutoDict.qml", {deck: fileName},
                                         false, false, true);
            lookup.start()
        }

        autoDict: UserSettings.autoDict
    }

    DecksModel{id: thisModel    //Contains some ListModels and handle some logic operation
        enumPopupDirection: popup.enumDirection
        Component.onCompleted: {
            dirViewModel.setPath(appSettings.readSetting(AppKeys.pathInSettings))
            //deckMedia.path = appSettings.readSetting(AppKeys.pathInSettings)
            setCategory(category)
        }
        onRequestCategorySelection: {mainView.categoryShow()}

        onRequestDialog: {
            dialog.hasTwoBtns =  hasTwoBtn
            dialog.hasInput = hasInput
            dialog.callback = callback
            dialog.setInputText(helper)
            dialog.show(msg)
        }
        onRequestPopup:{
            popup.menuModel = popupModel
            popup.callback = callback
            popup.show(direction)
        }
        onRequestCloudUl: {
            stackView.vtSwitchControl("qrc:/CloudDrive/CloudViewController.qml",
                 {isForDownload: false, uploadFileUrl: fullFileUrl, uploadCallback: callback },
                 false, false, true)
        }
        onRequestPleaseWait: {
            NWPleaseWait.callbackAfterForceRedraw = callback
            NWPleaseWait.visible = true;
            NWPleaseWait.state = "running";
            NWPleaseWait.message = message
        }
        onStopPleaseWait: {
            NWPleaseWait.visible = false;
            NWPleaseWait.state = "stopped";
        }
        onAddDeckDeleted: {
            var prop = {reminderDuration: 4000, remindCancelOption: false };
            var reminder = Create.instantComponent(root, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
            var message = qsTr("Deck of card adding is removed.\nCards will be added in lookup deck.")
            UserSettings.defaultAddDeck();
            reminder.cycleEndCallback = reminder.destroy;
            reminder.showReminder(message, reminder.enumDirection.left)
        }
        onCopyFailed: {
            var prop = {reminderDuration: 4000, remindCancelOption: false };
            var reminder = Create.instantComponent(root, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
            var message = qsTr("Deck copy failed.")
            reminder.cycleEndCallback = reminder.destroy;
            reminder.showReminder(message, reminder.enumDirection.left)
        }

    }

    NWDialogControl{id: dialog
        width: parent.width*2/3
    }

    NWPopupMenu{id: popup
        property var callback
        onItemClicked: { callback(id, index) }
    }

    QtObject{id: own

    }

    Component.onCompleted: {
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                Create.createComponent(root, tutorialQmlUrl, {width: root.width, height: root.height},
                                       startHanldeTutorial)
                break;
            }
        }
    }

    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property bool hasTutorial: false
    property variant tutArrayInThisQML: [UserSettings.tutPressAndHold]

    function startHanldeTutorial(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked)
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)

            if(!UserSettings.tutPressAndHold){
                pressAndHoldTutorial()
            }

        }
    }

    function pressAndHoldTutorial(){
        if(!UserSettings.tutPressAndHold){
            tutorial.tutorialKey = TutScript.tutPressAndHold
            tutorial.focusItem = mainView.decksListView
            tutorial.imageRatio = 0.9
            tutorial.start(600)
        }
    }

    function stopTutorial(key){
        tutorial.stop()
        UserSettings[key] = true
    }

    function foggyAreaClicked(){
        if(hasTutorial && tutorial.isOnGoing(TutScript.tutPressAndHold)){
            stopTutorial("tutPressAndHold")
        }
    }
    Component.onDestruction: {
        if(tutorial!=null) { tutorial.destroy() }
    }

}


