import QtQuick 2.0
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/objectCreate.js" as Create
import "qrc:/NWUIControls"
import "qrc:/NWDialog"
import "qrc:/controllers"
import "qrc:/../../UIControls"

// TODO: picture of entertainment, not transparent in picture...
Item { id: controller
    DragMouseAndHint {
        target: controller
        maxX: controller.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "right"
    }

    DeckManagementView{id: mainView
        onCloudClicked: {
            thisModel.cloudClicked()
        }
        onDeckCategoryClicked: {
            stackView.vtSwitchControl("qrc:/deckManagement/DecksController.qml", {category: id}
                                         , false, false, true);
        }
        onViewUnload: {
            stackView.popCurrentView()
        }
    }

    DeckManagementModel{id: thisModel    //Contains some ListModels and handle some logic operation
        enumPopupDirection: popup.enumDirection
        onRequestDialog: {
            dialog.hasTwoBtns =  hasTwoBtn
            dialog.hasInput = hasInput
            dialog.callback = callback
            dialog.show(text)
        }
        onRequestPopup: {
            popup.menuModel = popupModel
            popup.callback = callback
            popup.show(direction)
        }

        onRequestGgPubLinkDl:{
            NWPleaseWait.message = qsTr("Please wait...")
            NWPleaseWait.visible = true;
            NWPleaseWait.state = "running"
            NWPleaseWait.color = "#9fcdcd"
            ggPubLinkDl.startDownloadBy(url)
        }
        onRequestCouldDl: {
            stackView.vtSwitchControl("qrc:/CloudDrive/CloudViewController.qml", {}
                                         , false, false, true);
        }
    }


    NWDialogControl {id: dialog
        width: parent.width*2/3
    }

    NWPopupMenu{id: popup
        fontSize: UserSettings.fontPointSize
        property var callback
        menuModel: thisModel.popupModel
        onItemClicked: { callback(id, index) }
    }

    AppSettings{id: appSettings}
    GooglePublicLinkDownloader{id: ggPubLinkDl
        deckPath: appSettings.readSetting(AppKeys.pathInSettings)
        onDownloaded: {
            NWPleaseWait.visible = false
            own.checkDownload(pathName, fileName);
        }
        onDownloadFailed: {
            NWPleaseWait.visible = false;
            NWPleaseWait.state = "running"
            dialog.hasInput = false;
            dialog.hasTwoBtns = false;
            dialog.show(error);
            dialog.callback = (function (){return})
        }

        function handleProgressing(received, total){
            if(step == 2){
                var totalStr = total != 0 ? qsTr(("/ " + total.toFixed(2) + "M ")) : "" ;
                //: show users about received/total MB.
                NWPleaseWait.message = qsTr( "%1M %2received...").arg(received.toFixed(2)).arg(totalStr);
            }
        }
    }

    QtObject { id: own
        property var dynObj
        property int dlCards
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
    }
}

