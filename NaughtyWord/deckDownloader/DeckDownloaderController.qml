import QtQuick 2.0
import AppSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "../generalJS/appsettingKeys.js" as AppKeys
import "qrc:/NWDialog"

Item { id: root; anchors.fill: parent; visible: false

    function popupThisView(){
        waitComponentReadyTimer.start()
    }
    function pupdownThisView(){
        popupAnim.from = root.height - mainView.height - 6*vRatio
        popupAnim.to = root.height
        popupAnim.start()
        destroyTimer.start()
    }

    Timer{id: waitComponentReadyTimer; interval: 30
        onTriggered:{
            visible = true
            popupAnim.from = root.height
            popupAnim.to = root.height - mainView.height - 6*vRatio
            popupAnim.start()
        }
    }
    Timer{id: destroyTimer; interval: popupAnim.duration; onTriggered:  root.destroy() }

    AppSettings{id: appSettings}
    MouseArea{id: backgroundMosue; anchors.fill: parent
        property bool pleaseWaitWasVisible
        onClicked: {
            dialog.hasTwoBtns = true
            dialog.title = qsTr("Cancel download decks");
            pleaseWaitWasVisible = NWPleaseWait.visible
            NWPleaseWait.visible = false;
            dialog.callback = function () { pupdownThisView();}
            dialog.cancelCB = function () { NWPleaseWait.visible = pleaseWaitWasVisible;}
            dialog.show(qsTr("Are you sure you want to cancel download."));
        }
    }
    MouseArea{id: mouseStealer; anchors.fill: mainView
    }

    NumberAnimation {id: popupAnim
        target: mainView
        property: "y"
        duration: 600//Math.max(2000*mainView.height/parent.height, 300)
//        from: root.height; to: root.height - mainView.height - 6*vRatio
        easing.type: Easing.InOutQuad
    }

    DeckDownloaderPopupView{ id: mainView
        cateModel: categoryModel
        decksModel: displayModel
        delegator: own
        onCategoryClicked: {
            categoryModel.updateIsFilterOn(index, isOn)
            own.setFilters(index, isOn)
        }
        onDeckClicked: {
            thisModel.toggleIsClicked(index)
//            console.log("fileName",fileName)
        }
        onDlClicked: {
            var dlLists = thisModel.prepareDlLists()
            if(dlLists.length == 0){
                dialog.hasTwoBtns = false
                dialog.title = qsTr("Warning!");
                dialog.callback = function () {
                }
                dialog.show(qsTr("Please select decks first"));
            }else{
                NWPleaseWait.opacity = 0.8
                NWPleaseWait.message = ""
                NWPleaseWait.visible = true;
                NWPleaseWait.state = "running";
                dirViewModel.folderModel.countChanged.disconnect(own.folderModelChangedHandler)
                googleDl.startDownload(dlLists)
            }
        }
    }

    DeckDownloaderModel{id: thisModel
        Component.onCompleted: {
            dirViewModel.setPath(appSettings.readSetting(AppKeys.pathInSettings))
            dirViewModel.folderModel.countChanged.connect(own.folderModelChangedHandler)
//            console.log(appSettings.readSetting(AppKeys.pathInSettings))
        }
    }

    GoogleSequentialDownloader{id: googleDl
        deckPath: appSettings.readSetting(AppKeys.pathInSettings)
        onStartDlFile: {
            mainView.currentIndex = displayModel.findIndex(fileName.split(".")[0])
            thisModel.setDownloadStatus(fileName, qsTr("Connecting..."))
        }
        onFinishOneFile: {
//            console.log("path :", appSettings.readSetting(AppKeys.pathInSettings), "filenare:", fileName)
            own.unzipDeck(appSettings.readSetting(AppKeys.pathInSettings),fileName)
            thisModel.setDownloadStatus(fileName, qsTr("Downloaded"))
        }
        onOneFileFailed: { thisModel.setDownloadStatus(fileName, qsTr("Download failed")) }
        onProgressing: {
            thisModel.setDownloadStatus(fileName, qsTr("Received %1M").arg(received.toFixed(2)))
        }
        onAllFinished: {
            NWPleaseWait.opacity = 1
            NWPleaseWait.visible = false;
            if(hasError){
                dialog.hasTwoBtns = false
                dialog.title = qsTr("Warning!");
                dialog.callback = function () {
                    pupdownThisView()
                }
                dialog.show(qsTr("Due to network problem, not all decks were downloaded. You can try it later"));
            }else{
                pupdownThisView()
            }
        }
    }

    NWDialogControl{ id: dialog
        hasInput: false; hasTwoBtns: false
        width: parent.width*0.618
    }

    property alias categoryModel: thisModel.categoryModel
    property alias dirViewModel: thisModel.dirViewModel
    property alias displayModel: thisModel.displayModel


    QtObject{id: own
        function init(){
            categoryModel.fillModel()   //Dont mix the following code's order
            setFilters()
            /*After setting filters. folderModel will not be ready immediately.
            So use folderModel.countChanged signal to call folderModelChangedHandler() when folderModel is ready*/
        }

        function setFilters(){
            var filter = []
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).isFilterOn){ filter.push("*" + categoryModel.get(i).ext + ".*")}
            }
//            console.log("filter", filter)
            dirViewModel.setFilter(filter)
            /*Sometimes, changing category filter might not lead to folderModel's countChanged. But we still
            have to call displayModel.setModel() because some extensions are changed*/
            folderModelChangedHandler()
        }

        function folderModelChangedHandler(){
            displayModel.setModel()
        }

        function getImgBackground(ext){
//            console.log("ext",ext)
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).ext == ext){
                    return categoryModel.get(i).deckBg
                }
            }
        }
        function unzipDeck(path, file) {
            var zipper = Qt.createQmlObject('import Unzipper 0.1; Unzipper { }', thisModel);
            zipper.setZippedFileAndUnzip(path+file, path+file+"j")
            zipper.destroy()
            var dos = Qt.createQmlObject('import FileCommander 0.1; FileCommander { }', thisModel)
            dos.remove(path+file)
            dos.destroy()
        }
    }
    Component.onCompleted: {
        own.init()
    }

}

