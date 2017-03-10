import QtQuick 2.0
import com.glovisdom.UserSettings 0.1
import "../DirectoryView"
import "../generalModel"
import "qrc:/gvComponent"
import "decksViewConst.js" as Const
import "../generalJS/deckCategoryConsts.js" as CateConst
import "../DictLookup/vocabularyServer.js" as Server

Item {id: root
    property alias dirViewModel: dirViewModel
    property alias popupModel: popupModel
    property alias categoryModel: categoryModel
    property alias deckMedia: deckMedia
    property variant enumPopupDirection

    signal requestDialog(string msg, string helper, bool hasTwoBtn, bool hasInput, variant callback)
    signal requestPopup(variant popupModel, variant callback, int direction)
    signal requestCloudUl(string fullFileUrl, variant callback)
    signal requestCategorySelection()
    signal requestPleaseWait(string message, var callback)
    signal stopPleaseWait()
    signal addDeckDeleted()
    signal copyFailed()

    DirectoryModel{id: dirViewModel
        showDirs: true
    }

    ListModel { id: popupModel
        Component.onCompleted: {
            append({ id: Const.idRename, display: Const.disRename});
            append({ id: Const.idCopy, display: Const.disCopy });
            append({ id: Const.idDelete, display: Const.disDelete});
            append({ id: Const.idNewDeck, display: Const.disNewDeck });
            append({ id: Const.idSetAsCurrAdd, display: Const.disSetAsCurrAdd});
            append({ id: Const.idReassignCategory, display: Const.disReassignCategory});
//            append({ id: Const.idUlByWifi, display: Const.disUlByWifi });
//            append({ id: Const.idDlByWifi, display: Const.disDlByWifi});
            append({ id: Const.idUlToDrive, display: Const.disUlToDrive });
            append({ id: Const.idUlToDriveNoMeida, display: Const.disUlToDriveNoMeida });
            append({ id: Const.idCleanStudy, display: Const.disCleanStudy });
/*glovisdom internal use only. CAUTION: this function will overwrite existing word information
            append({ id: Const.idSaveImageURL, display: Const.disSaveImageURL });*/
        }
    }

    ListModel { id: popupModel2
        Component.onCompleted: {
            append({ id: Const.idNewDeck, display: Const.disNewDeck });
        }
    }

    ListModel{id: categoryModel
        Component.onCompleted: {
            append({key: CateConst.keyTest, isFilterOn: false,
                   imgSrcOn: "gameSelectDeck_Test01.png", imgSrcOff: "gameSelectDeck_Test02.png",
                   txt: CateConst.disTest, ext: CateConst.extTest})
            append({key: CateConst.keySchool, isFilterOn: false,
                    imgSrcOn: "gameSelectDeck_School01.png", imgSrcOff: "gameSelectDeck_School02.png",
                    txt: CateConst.disSchool, ext: CateConst.extSchool})
            append({key: CateConst.keyProfession, isFilterOn: false,
                    imgSrcOn: "gameSelectDeck_Profession01.png", imgSrcOff: "gameSelectDeck_Profession02.png",
                    txt: CateConst.disProfession, ext: CateConst.extProfession})
            append({key: CateConst.keyLife, isFilterOn: false,
                    imgSrcOn: "gameSelectDeck_Life01.png", imgSrcOff: "gameSelectDeck_Life02.png",
                    txt: CateConst.disLife, ext: CateConst.extLife})
            append({key: CateConst.keyEntertainment, isFilterOn: false,
                   imgSrcOn: "gameSelectDeck_Entertainment01.png", imgSrcOff: "gameSelectDeck_Entertainment02.png",
                   txt: CateConst.disEntertainment, ext: CateConst.extEntertainment})
            append({key: CateConst.keyTravel, isFilterOn: false,
                    imgSrcOn: "gameSelectDeck_Travel01.png", imgSrcOff: "gameSelectDeck_Travel02.png",
                    txt: CateConst.disTravel, ext: CateConst.extTravel})
        }
        function updateIsFilterOn(index, isOn){
            setProperty(index, "isFilterOn", isOn)
        }
    }

    DeckMedia{id: deckMedia;
        deck: "defaultDeck.kmrj"
        soundON: UserSettings.soundAllON
    }

    function setCategory(category){
        own.category = category
        dirViewModel.setFilter(["*" + own.extList[category] + ".*"])
    }

    function handlePropertyClicked(index){
        own.index = index
        own.copyFolderModel()
        requestPopup(popupModel, own.handleFilePopup, enumPopupDirection.up )
    }

    function handleMainIconClicked(){
        requestPopup(popupModel2, own.handleCategoryPopup, enumPopupDirection.up)
    }

    function reassignCategory(){
        var newName = own.modelItem.fileBaseName
        for(var i = 0 ; i < categoryModel.count; i++){
            if(categoryModel.get(i).isFilterOn){
                newName += categoryModel.get(i).ext
            }
        }
        newName += ".kmrj"
        own.rename(newName)
    }

    QtObject{id: own
        property int index
        property variant modelItem
        property int category: CateConst.idTest
        property variant extList: [
            CateConst.extTest, CateConst.extSchool, CateConst.extProfession,
            CateConst.extLife, CateConst.extEntertainment, CateConst.extTravel]
        property var dynamicObj
        function copyFolderModel(){
            var orgIndex = dirViewModel.dirModel.get(index).orgIndex
            modelItem = {}
            modelItem["fileName"] = dirViewModel.folderModel.get(orgIndex, "fileName")
            modelItem["filePath"] = dirViewModel.folderModel.get(orgIndex, "filePath")
            modelItem["fileURL"] = dirViewModel.folderModel.get(orgIndex, "fileURL")
            modelItem["fileBaseName"] = dirViewModel.folderModel.get(orgIndex, "fileBaseName")
            modelItem["fileSuffix"] = dirViewModel.folderModel.get(orgIndex, "fileSuffix")
            modelItem["fileSize"] = dirViewModel.folderModel.get(orgIndex, "fileSize")
            modelItem["fileModified"] = dirViewModel.folderModel.get(orgIndex, "fileModified")
            modelItem["fileAccessed"] = dirViewModel.folderModel.get(orgIndex, "fileAccessed")
            modelItem["fileIsDir"] = dirViewModel.folderModel.get(orgIndex, "fileIsDir")
        }

        function handleFilePopup(id){
            var orgName = modelItem["fileName"].split(".")[0];
            switch(id){
            case Const.idRename:
                requestDialog(qsTr("Please enter a new name"), orgName,
                              true, true, own.rename)
                break;
            case Const.idCopy:
                //Max:我覺得可以刪掉這個選項,沿用舊檔名就好,使用者想換名稱再去新複製的地點選“重新命名”
                //而且可以被ReassignCategory的功能取代
                requestDialog(qsTr("Please enter a name for the new copy"), orgName, true, true, own.copy)
                break;
            case Const.idDelete:
                requestDialog(qsTr("Are you sure to delete ") + orgName + "?", "", true, false, own.deleteDeck)
                break;
            case Const.idNewDeck:
                requestDialog(qsTr("Please enter a new name"), "", true, true, own.newDeck)
                break;
            case Const.idSetAsCurrAdd:
                requestDialog(qsTr("New cards will be added in this deck"), "", false, false, own.setAsCurrAdd)
                break;
    //        case Const.idUlByWifi:
    //            break;
    //        case Const.idDlByWifi:
    //            break;
            case Const.idUlToDrive:
                zipAndUpload(modelItem.filePath, false);
                break;
            case Const.idUlToDriveNoMeida:
                zipAndUpload(modelItem.filePath, true)
                break;
            case Const.idReassignCategory:
                for(var i = 0 ; i < categoryModel.count; i++){
                    categoryModel.setProperty(i, "isFilterOn", (modelItem.fileName.indexOf(categoryModel.get(i).ext) != -1))
                }
                requestCategorySelection()
                break;
            case Const.idCleanStudy:
                //:This is to give users a hint that they are going to reset all study records (excluding upgrade in stores)
                var msg = qsTr("Are you sure to reset all study records of <%1> (including card familiarity from playing games)?
                \n Notice! If you confirm, the records will be cleaned permanently.").arg(orgName)
                requestDialog(msg, "", true, false, own.resetAllStudy)
                break;
            case Const.idSaveImageURL:
                saveImageURL()
            }

        }
        function zipAndUpload(source, dbOnly) {
            var zipper = Qt.createQmlObject('import Unzipper 0.1; Unzipper { }', own);
            var zippedFile
            var target = source.substr(0, source.length-1);
            if(dbOnly) {
                zippedFile = zipper.setFilesAndZip([source+"/cards.sqlite3"], target)
            } else {
                zippedFile = zipper.setPathAndZip(source, target)
            }
            zipper.destroy();
            requestCloudUl(zippedFile, function() {
                dirViewModel.removeFullPathFiles([zippedFile], false)
            })
        }

        function rename(newName){
            if(newName == "") return
            if(newName.indexOf(".kmrj") == -1){
                newName = newName + "." + modelItem.fileSuffix
            }
            var oldName = modelItem.fileName
            if (dirViewModel.renameShortNameFile(modelItem.fileName, newName, true)) {
                if (UserSettings.addDeck == oldName) {
                    UserSettings.addDeck = newName
                }
            }
        }

        function copy(newName){
            if(newName == "") return
            var nameWithExtension = newName + "." + modelItem.fileSuffix
            if (!dirViewModel.copyShortNameFile(modelItem.fileName, nameWithExtension, true)) {
                copyFailed();
            } else {
                deckMedia.makeUnique(nameWithExtension)
            }
        }

        function deleteDeck(){
            var oldName = modelItem.fileName
            if (dirViewModel.removeShortNameFiles([modelItem.fileName], true)) {
                if (UserSettings.addDeck==oldName) { addDeckDeleted(); }
            }
        }

        function newDeck(newName){
            if(newName == "") return
            dirViewModel.newShortNameDeck(newName + extList[category] + ".kmrj")
        }

        function setAsCurrAdd(){
            UserSettings.addDeck = modelItem.fileName
        }

        function handleCategoryPopup(id, index){
            switch(id){
            case Const.idNewDeck:
                requestDialog(qsTr("Please enter a new name"), "",true, true, own.newDeck)
                break;
            }
        }

        function resetAllStudy(){
            deckMedia.setDeck(modelItem.fileName)
//TODO call anki reset history
            requestPleaseWait(qsTr("Please wait"), function (){
                deckMedia.clearHistory()
                stopPleaseWait()
            })
        }

        function saveImageURL(){
            deckMedia.setDeck(modelItem.fileName)

            requestPleaseWait(qsTr("Please wait"), function (){
            var totalCards = deckMedia.getRowCounts();
            for(var i = 0; i< totalCards; i++){
                var card = deckMedia.browse(i);

                if(typeof(card.imageURL) != "undefined" && card.imageURL != "" && card.imageURL != "null"){
                    var url = card.imageURL
                    if(card.imageURL.indexOf("mp3") != -1){
                        url = card.speechURL
                    }

                    Server.saveWordObj(card.word, {0: {count:1, imageURL: url}})
                }

            }
            stopPleaseWait()
            })
        }
    }
}

