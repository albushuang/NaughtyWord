import QtQuick 2.0
import FileCommander 0.1
import AppSettings 0.1
import SDictLookup 0.1
import Qt.labs.folderlistmodel 2.1
import "qrc:/deckManagement"
import "qrc:/../UIControls"
import "../NWUIControls"
import "../generalJS/objectCreate.js" as Create
import "../generalJS/appsettingKeys.js" as AppKeys

Item { id: controller;
    property var callback

    FolderListModel { id: thefolderModel
        nameFilters: [ "*", "*.*" ]
        showDirs: true
        folder: "file://"+appSettings.readSetting(AppKeys.dictionaryPath);
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
    DecksView{ id: view
        bgImg: "dictManagerView.png"
        folderModel: thefolderModel
        onCaregoryIconClicked: {
            Create.instantComponent(controller, "../controllers/Downloader.qml",
                               {width: view.width/1.7,
                                targetPath:appSettings.readSetting(AppKeys.dictionaryPath),
                                signalHanlder: own,
                                title: qsTr("Download dictionary"),
                                message: qsTr("Please input url:")
                                         + qsTr("\n(StarDict format)")})
        }
        onBackClicked: { stackView.pop(); }
        onDeckPressAndHold: {
            popMenuUp(thefolderModel.get(index, "fileName"));
        }
        onDeckClicked: { popMenuUp(fileName); }
        function popMenuUp(fileName) {
            var dictPath = appSettings.readSetting(AppKeys.dictionaryPath);
            popup.currentFilepath =  dictPath + fileName;
            popup.show(popup.enumDirection.up);
        }
    }

    AppSettings { id: appSettings }
    QtObject { id: own
        function handleDownloaded(loader, dialog) {
            unzipDictionary(loader.fileName);
            dialog.destroy()
        }
        function handleDownloadFailed(dialog) {
            console.log("download failed!!");
            dialog.destroy()
        }
        function unzipDictionary(filename) {
            console.log("unzipping...", appSettings.readSetting(AppKeys.dictionaryPath), filename);
            var dictManager = Qt.createQmlObject('import DictManager 0.1; DictManager { }',
                controller);
            if (dictManager.unPackRemovePackage(
                    preparePackage(appSettings.readSetting(AppKeys.dictionaryPath), filename))) {
                console.log("dictionary OK");
            }
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

    ListModel { id: theModel }

    NWPopupMenu{id: popup
        property string currentFilepath
        property bool renameDefault
        property var actions: [setDefault, renameDict, deleteDict];
        function setDefault() {
            if(sdict.setDictPath(currentFilepath)) {
                appSettings.writeSetting(AppKeys.defaultDictionary, currentFilepath);
            } else { console.log("not supported!"); }
        }
        function renameDict() {
            var message = qsTr("<b>Input new name:</b>");
            renameDefault = false
            var defaultDict = appSettings.readSetting(AppKeys.defaultDictionary);
            if (defaultDict==currentFilepath) {
                //: Tell the users that they are renaming the default dictionary
                message += "<br>" + qsTr("<font color=\"#A90036\">Default dictionary!!</font>")
                renameDefault = true;
            }
            Create.createComponent(controller, "qrc:/NWDialog/NWDialogControl.qml",
                                   {width: parent.width/1.7 },
                                   function (result, obj, qml) {
                                       var files = currentFilepath.split("/")
                                       obj.setInputText(files[files.length-1]);
                                       obj.show(message, getNewName);
                                   });
        }
        function getNewName(name) {
            if (dos.renameDir(currentFilepath, name)==true) {
                if (renameDefault) {
                    appSettings.writeSetting(AppKeys.defaultDictionary, name);
                }
            }
        }

        function deleteDict() {
            var defaultDict = appSettings.readSetting(AppKeys.defaultDictionary);
            console.log("deleting...", defaultDict)
            if (defaultDict==currentFilepath) {
                var obj = Create.instantComponent(controller, "qrc:/NWDialog/NWDialogControl.qml",
                                       { width: parent.width/1.7,
                                        hasTwoBtns: false, hasInput: false });
                //: Hint: User is about to delete default dictionary
                obj.show(qsTr("Are you sure to delete current used dictionary?"),
                         function() {
                               dos.removeDir(currentFilepath)
                               appSettings.writeSetting(AppKeys.defaultDictionary, "")
                         })
            } else {
                dos.removeDir(currentFilepath)
            }
        }

        SDictLookUp { id: sdict; maxResult: 1; }
        onItemClicked: {
            actions[id]();
        }

        Component.onCompleted: {
            theModel.append(new modelElement(0, qsTr("set main")));
            theModel.append(new modelElement(1, qsTr("rename")));
            theModel.append(new modelElement(2, qsTr("delete")));
            menuModel = theModel
        }
        FileCommander { id: dos }
    }
}
