import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import AnkiPackage 0.1
import com.glovisdom.UserSettings 0.1
import "../DirectoryView"
import "../generalJS/deckCategoryConsts.js" as CateConst
import "../generalJS/appsettingKeys.js" as AppKeys

//TODO try QtObject
Item {
    property alias categoryModel: categoryModel
    property alias dirViewModel: dirViewModel
    property alias displayModel: displayModel

    ListModel{id: categoryModel
        function fillModel() {
            append({key: CateConst.keyTest, isFilterOn: deckSelcSettings.test,
                   imgSrcOn: "gameSelectDeck_Test01.png", imgSrcOff: "gameSelectDeck_Test02.png",
                   deckBg: "qrc:/pic/gameSelectDeck_Test item.png",
                   txt: CateConst.disTest, ext: CateConst.extTest})
            append({key: CateConst.keySchool, isFilterOn: deckSelcSettings.school,
                    imgSrcOn: "gameSelectDeck_School01.png", imgSrcOff: "gameSelectDeck_School02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_School item.png",
                    txt: CateConst.disSchool, ext: CateConst.extSchool})
            append({key: CateConst.keyProfession, isFilterOn: deckSelcSettings.profession,
                    imgSrcOn: "gameSelectDeck_Profession01.png", imgSrcOff: "gameSelectDeck_Profession02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Profession item.png",
                    txt: CateConst.disProfession, ext: CateConst.extProfession})
            append({key: CateConst.keyLife, isFilterOn: deckSelcSettings.life,
                    imgSrcOn: "gameSelectDeck_Life01.png", imgSrcOff: "gameSelectDeck_Life02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Life item.png",
                    txt: CateConst.disLife, ext: CateConst.extLife})
            append({key: CateConst.keyEntertainment, isFilterOn: deckSelcSettings.entertainment,
                   imgSrcOn: "gameSelectDeck_Entertainment01.png", imgSrcOff: "gameSelectDeck_Entertainment02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Entertainment item.png",
                   txt: CateConst.disEntertainment, ext: CateConst.extEntertainment})
            append({key: CateConst.keyTravel, isFilterOn: deckSelcSettings.travel,
                    imgSrcOn: "gameSelectDeck_Travel01.png", imgSrcOff: "gameSelectDeck_Travel02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Travel item.png",
                    txt: CateConst.disTravel, ext: CateConst.extTravel})
        }
        function updateIsFilterOn(index, isOn){
            setProperty(index, "isFilterOn", isOn)
        }
    }

    FolderListModel { id: ankiFolder
        nameFilters: [ "*", "*.*" ]
        showDirsFirst: true
        showDirs: true
        folder: "file://"+appSettings.readSetting(AppKeys.ankiPackagePath);
    }

    AnkiPackage { id: ankiPack }

    DirectoryModel{ id: dirViewModel
        showDirs: true
        /*When a deck belongs to multi categories(multi-extension), we want to display that deck for many times.
        Folder list model cannot fulfill this criteria so we create our own file model*/
        ListModel{id: displayModel
            function setModel(){
                displayModel.clear()//TODO order is not right
//                console.log("files count", categoryModel.count)
                var folderModel = dirViewModel.folderModel
                var hasAddedLookup = false
                for(var j = 0; j < categoryModel.count ; j++){
                    if(!categoryModel.get(j).isFilterOn){continue;}
                    for(var i = 0; i < folderModel.count; i++){
                        var fullFileName = folderModel.get(i, "fileName")
                        if(fullFileName.indexOf(categoryModel.get(j).ext) != -1){
                            if(fullFileName.indexOf(UserSettings.lookup.split(".")[0]) == -1){
                                append({fileName: folderModel.get(i, "fileBaseName") + categoryModel.get(j).ext,
                                       fullFileName: fullFileName})
                            }else if(!hasAddedLookup){
                                hasAddedLookup = true
                                append({fileName: folderModel.get(i, "fileBaseName") + categoryModel.get(j).ext,
                                       fullFileName: fullFileName})
                            }
                        }
                    }
                    if(categoryModel.get(j).key==CateConst.keyTest) {
                        var base = appSettings.readSetting(AppKeys.ankiPackagePath)
                        if(base[base.length-1]!="/") base += "/"
                        for(var i=0;i<ankiFolder.count;i++) {
                            if(ankiPack.isAnkiPackage(base + ankiFolder.get(i, "fileName"))) {
                                append({fileName: ankiFolder.get(i, "fileBaseName") + categoryModel.get(j).ext,
                                       fullFileName: "anki/" + ankiFolder.get(i, "fileName")})
                            }
                        }
                    }
                }
            }
        }
    }
}

