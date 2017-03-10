import QtQuick 2.0
import QtQuick.Controls 1.4
import com.glovisdom.NWPleaseWait 0.1
import com.glovisdom.UserSettings 0.1
import "qrc:/../UIControls"
import "qrc:/NWDialog"
import "qrc:/NWUIControls"
import "CloudConst.js" as Consts
import "../generalJS/objectCreate.js" as Create

Rectangle {id: root;

    property bool isForDownload: true   //The view might be used for upload purpose
    property string uploadFileUrl: ""
    property var uploadCallback
    property bool dragExit: false
    property LogInView logInView

    DragMouseAndHint {
        target: root
        maxX: root.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
        //Component.onDestruction: logInView.webView.visible = false // webView.visible has to be false, since it can't be popped out.
    }
//TODO add guard timer when NWPleaseWait.visible = true
    CloudModel{id: thisModel
        property int dlCards
        property var dynObj
        driveType: own.driveType
        uploadFileUrl: root.uploadFileUrl
        viewMyDrive: own.viewMyDrive
        enumPopupDirection: popupMenu.enumDirection
        onModelsReady: {
            if(own.driveType == Consts.googleDrive){
                cloudView.rootId = thisModel.getRootId(own.viewMyDrive)
                cloudView.updateCurrFolder(thisModel.getRootId(own.viewMyDrive), "root")
            }else if(own.driveType == Consts.dropBox){
                cloudView.updateCurrFolder(Consts.fakeRootId, "root")
            }
            NWPleaseWait.visible = false
        }        
        onDownloaded: {
            NWPleaseWait.visible = false
            checkDownload(pathName, fileName);
        }
        function checkDownload(path, file) {
            unzipDeck(path, file);
            dialog.hasTwoBtns =  true;
            //: This text show users the button is for downloading image and sound
            dialog.title = qsTr("Download media");
            dialog.hasInput = false;
            dialog.callback = function () {
                var filler = 'import DBFiller 0.1; DBFiller { }';
                dynObj = Qt.createQmlObject(filler, stackView);
                if (path[path.length-1]!='/') path += "/";
                dlCards = 0
                dynObj.oneRecordDone.connect(reportOneRecord)
                dynObj.fillDone.connect(reportAllRecord)
                invokeWait(dynObj);
                dynObj.getMediaFullPath(path+file+"j/cards.sqlite3", "cardTable");
            }
            dialog.show(qsTr("Get media for downloaded deck?"));
        }


        function unzipDeck(path, file) {
            var zipper = Qt.createQmlObject('import Unzipper 0.1; Unzipper { }', thisModel);
            zipper.setZippedFileAndUnzip(path+file, path+file+"j")
            zipper.destroy()
            var dos = Qt.createQmlObject('import FileCommander 0.1; FileCommander { }', thisModel)
            dos.remove(path+file)
            dos.destroy()
        }

        function invokeWait(dynamicObj) {
            NWPleaseWait.hasButton = true;
            NWPleaseWait.buttonClicked = moveToBackground;
            //: Back(Exit) to background
            NWPleaseWait.buttonText = qsTr("To background")
            // NWPleaseWait.callbackData = {downloader: dynamicObj}
            NWPleaseWait.message = dlCards + qsTr(" downloaded...")
            NWPleaseWait.visible = true;
            NWPleaseWait.state = "running"
        }
        function moveToBackground(data) {
            NWPleaseWait.visible = false;
            NWPleaseWait.hasButton = false;
            // var obj = data.downloader // not used anymore
            dynObj.onOneRecordDone.disconnect(reportOneRecord)
            dynObj.onFillDone.disconnect(reportAllRecord);
        }

        function reportOneRecord(update) {
            dlCards++
            NWPleaseWait.message = dlCards + qsTr(" downloaded...")
        }
        function reportAllRecord() {
            NWPleaseWait.visible = false;
            NWPleaseWait.hasButton = false;
            dynObj.onOneRecordDone.disconnect(reportOneRecord)
            dynObj.onFillDone.disconnect(reportAllRecord);
            deleteLater.interval = 1
            deleteLater.toDo = delModelObj
            deleteLater.start()
        }
        function delModelObj() {
            thisModel.dynObj.destroy();
            thisModel.dynObj = (function(){}())
        }

        Timer { id: deleteLater
            property var toDo
            triggeredOnStart: false; interval: 1; repeat: false
            onTriggered: { toDo() }
        }

        onUploaded: {
            NWPleaseWait.visible = false
            NWPleaseWait.hasButton = false
            uploadCallback(true);
            uploadCallback = (function(){}())
        }
        onProgressing: {own.handleProgressing(received, total, isDL)}
        onDownloadFailed: {
            NWPleaseWait.visible = false;
            console.assert(false, error)
        }
        onUploadFailed: {
            NWPleaseWait.visible = false
            uploadCallback(false);
            uploadCallback = (function(){}())
            console.assert(false, error)
            stackView.pop()
        }
        onRequestLogin: {
            NWPleaseWait.visible = false
            own.showLogin();
            logInView.startLogIn(authUrl)
        }
        onRequestDialog: {
            dialog.hasTwoBtns =  hasTwoBtn; dialog.title = title
            dialog.hasInput = hasInput; dialog.callback = callback
            dialog.show(text)
        }
        onReqeustWaiting: {
            NWPleaseWait.message = text
            NWPleaseWait.visible = isOn
            NWPleaseWait.state = isOn ? "running" : "stopped"
            if(logInView!=null) {
                deleteLater.interval = 2000
                deleteLater.toDo = delLoginView
                deleteLater.start()
            }
        }
        function delLoginView() {
            logInView.visible = false
        }

        onRequestPopup: {
            popupMenu.menuModel = popupModel
            popupMenu.callback = callback
            popupMenu.show(direction)
        }
        onGoBack: {
            NWPleaseWait.visible = false;
            if(typeof(uploadCallback)!="undefined") {
                uploadCallback(true);
                uploadCallback = (function(){}())
            }
            stackView.pop()
        }
    }


    CloudView{id: cloudView
        fontPointSize: UserSettings.fontPointSize
        rowSpace: 8
        driveType: own.driveType
        isForDownload: root.isForDownload
        viewMyDrive: own.viewMyDrive
        folderModel: own.viewMyDrive? thisModel.myFolderModel : thisModel.sharedFolderModel
        fileModel: own.viewMyDrive? thisModel.myFileModel : thisModel.sharedFileModel
        onDriveTypeSelected:{
            own.driveType = type
            own.showDriveContent()
        }
        onMyDriveOrSharingSelected: {
            own.viewMyDrive = isMyDrive
            cloudView.rootId = thisModel.getRootId(own.viewMyDrive)
            cloudView.updateCurrFolder(thisModel.getRootId(own.viewMyDrive), "root")
        }
        onFileClicked: {
            thisModel.handleFileClicked(index, theItem)
        }
        onSettingsClicked: {
            thisModel.handleSettingClicked(index, theItem)
        }
        onUploadBtnClicked: {
            thisModel.handleUploadClicked(currFolderId)
        }
//TODO on android, it will crash......don't know why yet
        onLeaveCloudDrive: {
            exitCloudDrive()
        }
        onRequestLogout: {
            own.showLogin()
            thisModel.logoutModel();
        }
    }

    function exitCloudDrive(){
        if(logInView!=null) { logInView.webView.visible = false }
        NWPleaseWait.visible = false;
        if (typeof(uploadCallback)!="undefined") uploadCallback(false);
        stackView.pop()
    }

    NWDialogControl{ id: dialog
        hasInput: false
        width: parent.width*0.618
    }

    NWPopupMenu{ id: popupMenu;
        property var callback
        onItemClicked: {
            callback(id, index)
        }
    }

    TextInput{id: clipboard; visible: false}    //Use textinput to access clipboard


    Component.onCompleted: {
        NWPleaseWait.color = "lightBlue"
    }
    Component.onDestruction: {
        NWPleaseWait.setAsDefault(application)
        if (typeof(uploadCallback)!="undefined") { uploadCallback(false) }
        if (typeof(dynObj)!="undefined") { moveToBackground({}) }
        if (logInView!=null) { logInView.destroy() }
    }

    QtObject{id: own
        property string driveType
        property bool viewMyDrive: true // false means view the files from sharing from the other ppl
        function handleProgressing(received, total, isDL) { // protocol of file downloader
            var totalStr = total != 0 ? ("/ " + total.toFixed(2) + "M ") : "" ;
            //: the following message is to tell the user the progress of downloading
            //: about how much is already download
            if(isDL || typeof(isDL) == "undefined"){
                NWPleaseWait.message = qsTr( "%1M %2received...").arg(received.toFixed(2)).arg(totalStr);
            }else{
                NWPleaseWait.message = qsTr( "%1M %2transferred...").arg(received.toFixed(2)).arg(totalStr);
            }
        }
        function showDriveContent(){
            NWPleaseWait.message = qsTr("Connecting...Please wait")
            NWPleaseWait.visible = true
            NWPleaseWait.state = "running"
            thisModel.start()
            //showLogin()
        }
        function showLogin() {
            if(logInView!=null) return
            var prop = {
                driveType: driveType
            }
            logInView = Create.instantComponent(root, "qrc:/CloudDrive/LogInView.qml", prop)
            logInView.authCodeUpdated.connect(thisModel.handleGgAuthCodeUpaded)
            logInView.dropboxAuthFinished.connect(thisModel.handleDropboxAuthFinished)
            logInView.logoutCompelete.connect(thisModel.start)
            logInView.leaveCloudDrive.connect(exitCloudDrive)
        }
    }
}

