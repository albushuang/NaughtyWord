import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import AnkiPackage 0.1
import "../DirectoryView"
import "../generalJS/deckCategoryConsts.js" as CateConst
import "../generalJS/appsettingKeys.js" as AppKeys

//TODO try QtObject
Item {
    property alias categoryModel: categoryModel
    property alias dirViewModel: dirViewModel
    property alias displayModel: displayModel

    function toggleIsClicked(index){
        for(var i = 0; i < displayModel.count; i++){
            if(displayModel.get(i).fileName.split(".")[0] == displayModel.get(index).fileName.split(".")[0]){
                displayModel.setProperty(i, "isClicked", !displayModel.get(i).isClicked)
            }
        }
    }

    function prepareDlLists(){
        var finalDlLists = []
        for(var i = 0; i < dlLists.length; i++){
            var downloadThisOne = false
            for(var j = 0; j < displayModel.count; j++){
                if(displayModel.get(j).fullFileName.split(".")[0] == dlLists[i].name.split(".")[0] &&
                   displayModel.get(j).isClicked == true ){
                    downloadThisOne = true
                }
            }
            if(downloadThisOne){ finalDlLists.push(dlLists[i])}
        }
        return finalDlLists
    }

    function setDownloadStatus(fileName, message){
        for(var j = 0; j < displayModel.count; j++){
            if(displayModel.get(j).fullFileName.split(".")[0] == fileName.split(".")[0] ){
                displayModel.setProperty(j, "downloadStatus", message)
                //Do not break, because there might be more than one element has the same basic name
            }
        }
    }

    ListModel{id: categoryModel
        function fillModel() {
            append({key: CateConst.keyTest, isFilterOn: true,
                   imgSrcOn: "gameSelectDeck_Test01.png", imgSrcOff: "gameSelectDeck_Test02.png",
                   deckBg: "qrc:/pic/gameSelectDeck_Test item.png",
                   txt: CateConst.disTest, ext: CateConst.extTest})
            append({key: CateConst.keySchool, isFilterOn: true,
                    imgSrcOn: "gameSelectDeck_School01.png", imgSrcOff: "gameSelectDeck_School02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_School item.png",
                    txt: CateConst.disSchool, ext: CateConst.extSchool})
            append({key: CateConst.keyProfession, isFilterOn: true,
                    imgSrcOn: "gameSelectDeck_Profession01.png", imgSrcOff: "gameSelectDeck_Profession02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Profession item.png",
                    txt: CateConst.disProfession, ext: CateConst.extProfession})
            append({key: CateConst.keyLife, isFilterOn: true,
                    imgSrcOn: "gameSelectDeck_Life01.png", imgSrcOff: "gameSelectDeck_Life02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Life item.png",
                    txt: CateConst.disLife, ext: CateConst.extLife})
            append({key: CateConst.keyEntertainment, isFilterOn: true,
                   imgSrcOn: "gameSelectDeck_Entertainment01.png", imgSrcOff: "gameSelectDeck_Entertainment02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Entertainment item.png",
                   txt: CateConst.disEntertainment, ext: CateConst.extEntertainment})
            append({key: CateConst.keyTravel, isFilterOn: true,
                    imgSrcOn: "gameSelectDeck_Travel01.png", imgSrcOff: "gameSelectDeck_Travel02.png",
                    deckBg: "qrc:/pic/gameSelectDeck_Travel item.png",
                    txt: CateConst.disTravel, ext: CateConst.extTravel})
        }
        function updateIsFilterOn(index, isOn){
            setProperty(index, "isFilterOn", isOn)
        }
    }

    property var dlLists:
        [  {name: "TOEFL 400.tst.kmr", baseName: "TOEFL 400",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6WUh5bW9JU0Z1eW8/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoWGdMOFhJNlE5Zjg/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbcTZyUWNtdWVKb0E/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsQlVxVjVHQTVyNVE/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5TnMxWGo5MjN6a2s/view?usp=sharing"]},
           {name: "TOEIC 850 (1 of 2).tst.kmr", baseName: "TOEIC 850 (1 of 2)",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6YTFCLVZXTkRJRTQ/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoVFBodms2a2w4aU0/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbcXZUZzY1ektNajA/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsNVBjNjVEdFJvQk0/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5N3dfbjdFcTRsRDA/view?usp=sharing"]},
           {name: "TOEIC 850 (2 of 2).tst.kmr", baseName: "TOEIC 850 (2 of 2)",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6d3VHRHBDcnRHMWM/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoTklVam5nTFlaOGs/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbektST0ZvNzN1aEU/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsU0R1dUppUjdjLU0/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5X0hfOXAyaXhoOUk/view?usp=sharing"]},
           {name: "pasta & dessert.lif.tvl.kmr", baseName: "pasta & dessert",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6allnYlJtSjN0QTQ/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoR2ZEMmMtYld1eTg/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbdGs1Sl9VMDF2S1k/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsbl9DazU1X2lyazQ/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5RmpKUk9NX0ltdGs/view?usp=sharing"]},
           {name: "antipasti.lif.tvl.kmr", baseName: "antipasti",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6WDVRUXRNcVNkZzA/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQodjZrTWZzVXRfR0k/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbb1NDLWc0d3RKcmc/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsUmI0RmZYa1ZNdGM/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5SFNHaHdidlBMYms/view?usp=sharing"]},
           {name: "cities.tvl.kmr", baseName: "cities",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6NzE1LXJ2WFhpUVU/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoZDVnaFRKQU9zUjA/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbZmZ3U190WWFNMWM/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsYmoxbmY4QmYyUlk/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5aEhCQVEyUV96LWM/view?usp=sharing"]},
           {name: "animals.lif.kmr", baseName: "animals",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6aVVHalVEcVhzNlU/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoT2VGQWFyRTFDYlU/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbZVNsRGJlajdQYnM/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQscjhxX1B3TWVIM0U/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5NmR2ZU0yamlib0k/view?usp=sharing"]},
           {name: "fruits.lif.kmr", baseName: "fruits",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6RWlrZlowekQwZ2c/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoRTdvMnFxcmN2NU0/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbRW9sTGdHMGM2Y2M/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsYmE4Q3F3MVFsc2c/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5eEFMTkU2NzhUaFE/view?usp=sharing"]},
           {name: "mains.lif.tvl.kmr", baseName: "mains",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6M3hvdmZpekpmcE0/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoRW8wdWstaU9HUkU/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbX1dES0lUT00wQkk/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsSkRaWW1fa1V1ckk/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5SmJ3eEhoSkoxc1U/view?usp=sharing"]},
           {name: "RPG.etm.kmr", baseName: "RPG",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6T2VNQktUYkNKdGs/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoM0RFdzdLSW5nWms/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbX2M2R1VrdUJ0anc/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsSkdUSEdHXzk1VzQ/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5WVhuQ1J0aTZYakU/view?usp=sharing"]},
           {name: "common medicine.pro.kmr", baseName: "common medicine",
            dlUrlLists:
                ["https://drive.google.com/file/d/0BwFQXnn8vUf6eEpWTEpkYWlubFU/view?usp=sharing",
                "https://drive.google.com/file/d/0B-mGaqTQ0NQoLUtDSXVoWnNwMzA/view?usp=sharing",
                "https://drive.google.com/file/d/0B3MnZ893I1zbNF95cG13bExwVjA/view?usp=sharing",
                "https://drive.google.com/file/d/0B7we4oqwPhQsWVN4X3VXX1doWm8/view?usp=sharing",
                "https://drive.google.com/file/d/0B7F71N1LTlB5S1FvbmYwbmllV1U/view?usp=sharing"]}
        ]

    DirectoryModel{ id: dirViewModel
        showDirs: true
        /*When a deck belongs to multi categories(multi-extension), we want to display that deck for many times.
        Folder list model cannot fulfill this criteria so we create our own file model*/
        ListModel{id: displayModel
            function setModel(){
                displayModel.clear()
//                console.log("files count", categoryModel.count)
                for(var j = 0; j < categoryModel.count ; j++){
                    if(!categoryModel.get(j).isFilterOn){continue;}
                    for(var i = 0; i < dlLists.length; i++){
                        var hasDownloaded = false
                        for(var k = 0; k < dirViewModel.folderModel.count; k++){
                            if(dirViewModel.folderModel.get(k, "fileName").indexOf(dlLists[i].name) != -1){
                                hasDownloaded = true; break;
                            }
                        }

                        if(!hasDownloaded && dlLists[i].name.indexOf(categoryModel.get(j).ext) != -1){
                            append({fileName: dlLists[i].baseName + categoryModel.get(j).ext,
                                   fullFileName: dlLists[i].name,
                                   isClicked: false,
                                   downloadStatus: qsTr("Not downloaded")})
                        }
                    }
                }
            }
            function findIndex(baseName){
                for(var j = 0; j < displayModel.count; j++){
                    if(displayModel.get(j).fullFileName.split(".")[0] == baseName ){
                        return j
                    }
                }
            }
        }
    }

}

