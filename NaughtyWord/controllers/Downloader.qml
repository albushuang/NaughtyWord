import QtQuick 2.0
import FileDownloader 0.1
import com.glovisdom.NWPleaseWait 0.1
import com.glovisdom.UserSettings 0.1
import "qrc:/NWDialog"
import "../generalJS/objectCreate.js" as Create

Item { id: controller
    property var signalHanlder
    property bool saveAsFile: true
    property string targetPath
    property alias title: dialog.title
    property alias message: dialog.message
    property alias messageObj: dialog.messageObj
    anchors.centerIn: parent
    height: dialog.height

    NWDialog { id: dialog
        anchors.fill: parent
        width: parent.width
        delegator: own
        state: "inputAndTwoButtons"
    }
    QtObject { id: own
        function yesClicked(text) {
            Qt.inputMethod.hide()
            dialog.visible = false
            getFromUrlAndSave(text)
        }

        function noClicked(text) {
            Qt.inputMethod.hide()
            dialog.visible = false
            controller.destroy();
        }
    }

    FileDownloader { id: loader
        onProgressing: { handleProgressing(received, total);}
        onDownloaded: { NWPleaseWait.visible = false; signalHanlder.handleDownloaded(loader, controller);  }
        onDownloadFailed: { NWPleaseWait.visible = false; signalHanlder.handleDownloadFailed(controller);  }
    }
    function handleProgressing(received, total) {
        var totalStr = total != 0 ? ("/ " + total.toFixed(2) + "M ") : "" ;
        NWPleaseWait.message = qsTr( "%1M %2received...").arg(received.toFixed(2)).arg(totalStr);
    }
    function getFromUrlAndSave(url) {
        if(saveAsFile) {
            loader.storagePath = targetPath
            loader.fileName = getFileName(url);
        }
        loader.fileUrl = url;
        NWPleaseWait.visible = true
    }

    function getFileName(url) {
        var names = url.split("/");
        return names[names.length-1];
    }
    Component.onCompleted: {
        NWPleaseWait.color = "#9fcdcd"
        NWPleaseWait.state = "running"
        NWPleaseWait.externalFontSize = UserSettings.fontPointSize
    }
    Component.onDestruction: {
        NWPleaseWait.setAsDefault(application)
    }
}
