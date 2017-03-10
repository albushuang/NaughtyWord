import QtQuick 2.0
import FileCommander 0.1
import AppSettings 0.1
import Qt.labs.folderlistmodel 2.1
import com.glovisdom.UserSettings 0.1
import Unzipper 0.1
import "qrc:/deckManagement"
import "qrc:/../../UIControls"
import "../NWUIControls"
import "../generalJS/objectCreate.js" as Create
import "../generalJS/appsettingKeys.js" as AppKeys

Item { id: controller;
    property var callback

    FolderListModel { id: thefolderModel
        nameFilters: [ "*", "*.*" ]
        showDirsFirst: true
        showDirs: true
        folder: "file://"+appSettings.readSetting(AppKeys.ankiPackagePath);
    }
    DragMouseAndHint {
        target: controller
        maxX: controller.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
    }

    Text { id: ankiWebSite
        text: qsTr("Please input url:") +
              qsTr("<br>or<br>Visit webpage of <u>Anki decks</u>")
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        visible: false
        font.pointSize: UserSettings.fontPointSize
        MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("https://ankiweb.net/shared/decks/english") } }
        z: 100
        color: "white"
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
    }

    DecksView{ id: view
        bgImg: "dictManagerView.png"
        folderModel: thefolderModel
        onCaregoryIconClicked: {
            var dialog = Create.instantComponent(controller, "../controllers/Downloader.qml",
                               {width: view.width/1.7,
                                targetPath:appSettings.readSetting(AppKeys.ankiPackagePath),
                                signalHanlder: own,
                                saveAsFile: false,
                                title: qsTr("Anki Decks download"),
                                message: ""})
            ankiWebSite.parent = dialog.messageObj
            ankiWebSite.width = dialog.width*0.9
            ankiWebSite.visible = true
        }
        onBackClicked: { stackView.pop(); }
        onDeckPressAndHold: {
            popMenuUp(thefolderModel.get(index, "fileName"));
        }
        onDeckClicked: { own.checkAnkiOpen(fileName, index) }
        function popMenuUp(fileName) {
            var dictPath = appSettings.readSetting(AppKeys.ankiPackagePath);
            popup.currentFilepath =  dictPath + fileName;
            popup.show(popup.enumDirection.up);
        }
    }
    Unzipper { id: unzip }

    QtObject { id: own
        function checkAnkiOpen(fileName) {
            var folder = thefolderModel.folder + ""
            if(folder[folder.length-1]!="/") folder += "/"
            if(checkAnki2(folder+fileName)) {
                if(folder.slice(0,5)=="file:") { folder = folder.slice(7) }
                stackView.vtSwitchControl("qrc:/deckManagement/AnkiViewController.qml",
                                             { path: folder+fileName },
                                             false, false, true);
            } else {
                var obj = Create.instantComponent(controller, "qrc:/NWDialog/NWDialogControl.qml",
                                       { width: parent.width/1.7,
                                        hasTwoBtns: false, hasInput: false });
                obj.show(qsTr("Not Anki Package"), function() { obj.destroy() })
            }
        }
        function checkAnki2(path) {
            var obj = Qt.createQmlObject('import FileCommander 0.1; FileCommander { }', own);
            if(path[path.length-1]!="/") path += "/"
            var result = obj.exists(path+"collection.anki2")
            obj.destroy()
            return result
        }

        function handleDownloaded(loader, dialog) {
            popup.currentFilepath = preparePath(loader.fileName)
            // TODO: should handle wrong zip file etc...or app crashes.
            unzip.setZippedBufferAndUnzip(loader.downloadedData, popup.currentFilepath)
            popup.resetDeck()
            dialog.destroy()
        }
        function preparePath(fileName) {
            var lastDot = fileName.lastIndexOf(".")
            return appSettings.readSetting(AppKeys.ankiPackagePath) + fileName.slice(0,lastDot)
        }

        function handleDownloadFailed(dialog) {
            console.log("download failed!!");
            dialog.destroy()
        }
    }

    AppSettings { id: appSettings }

    // ======================================================

    ListModel { id: theModel }

    NWPopupMenu{id: popup
        property string currentFilepath
        property bool renameDefault
        property var actions: [renameDeck, deleteDeck, resetDeck];

        function renameDeck() {
            var message = qsTr("<b>Input new name:</b>");
            Create.createComponent(controller, "qrc:/NWDialog/NWDialogControl.qml",
                                   {width: parent.width/1.7 },
                                   function (result, obj, qml) {
                                       var files = currentFilepath.split("/")
                                       obj.setInputText(files[files.length-1]);
                                       obj.show(message, getNewName);
                                   });
        }
        function deleteDeck() {
            dos.remove(currentFilepath)
        }
        function resetDeck() {
            var anki = Qt.createQmlObject('import AnkiPackage 0.1; AnkiPackage { }', controller)
            anki.openPackage(currentFilepath)
            anki.clearHistory()
            delete anki
        }

        function getNewName(name) {
            dos.renameDir(currentFilepath, name)
        }

        onItemClicked: {
            actions[id]();
        }

        Component.onCompleted: {
            theModel.append(new modelElement(0, qsTr("rename")));
            theModel.append(new modelElement(1, qsTr("delete")));
            theModel.append(new modelElement(2, qsTr("reset deck")));
            menuModel = theModel
        }
        FileCommander { id: dos }
    }

    function getFileName(url) {
        var names = url.split("/");
        return names[names.length-1];
    }

    function prepareSystemPath(path) {
        if (path.slice(0, 6)==="file://") path = path.slice(7);
        if (path.charAt(path.length-1) != '/') path += "/";
        return path;
    }

    function preparePackage(path, file) {
        return prepareSystemPath(path) + file;
    }
}
