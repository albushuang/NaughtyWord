import QtQuick 2.0
import com.glovisdom.UserSettings 0.1
import com.glovisdom.AnkiDeck 0.1
import "viewConsts.js" as Consts
import "../generalJS/chooseDeck.js" as Choose
import "../generalJS/appsettingKeys.js" as AppKeys
import "qrc:/generalModel"

ListModel{id: studyInfoModel
    property var appSettings
    property var modelDatas
    property var deckMedia
    property int titleLv:0
    Component.onCompleted: {
        /*the information in "items" might be various length. ListElement do not support Object or Array type
        (only str, int, enum ). So we need to create an variable called "modelDatas".*/

        var initItems = [{item:"", value:0}, {item:"", value:0}, {item:"", value:0}]
        modelDatas = {thisDeck: {deckName: "", items: initItems},
                        allDeck: {deckName: "", items: initItems},
                        todaySchedule: {deckName: "", items: initItems}
                    }

        /*Here in the model, we only save key*/
        append({itemKey: Consts.keyAllDeck})
        append({itemKey: Consts.keyTodaySchedule})
        append({itemKey: Consts.keyThisDeck})        
    }

    function updateStudyInfo(deck, dirModel, updateAllDeckInfo){
        deckMedia = Choose.createMedia(view,
                   appSettings.readSetting(AppKeys.pathInSettings),
                   { deck: UserSettings.gameDeck, soundON: UserSettings.soundGameON })

        var deckName = (deck.split(".")[0]).replace(/.*\//, "")
//        console.log("basic deckName:", deckName)
        fillThisDeckInfo(deckName)
        if(updateAllDeckInfo){ fillAllDeckInfo(dirModel)}

        deckMedia.destroy()
    }

    function fillThisDeckInfo(deckName){
        var news = deckMedia.getRowCounts(AnkiDeck.StatusNew)
        var mastered = deckMedia.getRowCounts(AnkiDeck.Mastered)
        var learned = deckMedia.getRowCounts(AnkiDeck.StudyAll) - mastered
        modelDatas[Consts.keyThisDeck] = {deckName: deckName + qsTr("information"),
            items: [{item:qsTr("Unknown"), value:news},
                    {item:qsTr("Learned"), value:learned},
                    {item:qsTr("Mastered"), value:mastered}]
        }
        var todayNews = UserSettings.newCardsLeftToday
        var learning = deckMedia.getRowCounts(AnkiDeck.StatusLearning)
        var dueToday = deckMedia.getRowCounts(AnkiDeck.StatusReviewDueToday)
        modelDatas[Consts.keyTodaySchedule] = {deckName: qsTr("Today's schedule of %1").arg(deckName),
            items: [{item:qsTr("New"), value:todayNews},
                    {item:qsTr("Learning"), value:learning},
                    {item:qsTr("Review"), value:dueToday}]
        }
        modelDatas = modelDatas

        saveStudyInfoToUsageServer(deckName, news, learned, mastered)
    }

    function fillAllDeckInfo(dirModel){
        var news = 0
        var mastered = 0
        var learned = 0
//        console.log("calculating all study info, when there are ", dirModel.folderModel.count, "decks in model")
        for(var i = 0; i < dirModel.folderModel.count; i++){
            var fn = dirModel.folderModel.get(i, "fileName")
            if (fn=="anki") continue
            deckMedia.setDeck(fn)
            news += deckMedia.getRowCounts(AnkiDeck.StatusNew)
//            console.log(dirModel.folderModel.get(i, "fileName"), "mastered:", mastered, "learned", learned)
            var tempMastered = deckMedia.getRowCounts(AnkiDeck.Mastered)
            mastered += tempMastered
            learned += (deckMedia.getRowCounts(AnkiDeck.StudyAll) - tempMastered)
        }

        modelDatas[Consts.keyAllDeck] = {deckName: qsTr("All decks"),
            items: [{item:qsTr("Unknown"), value:news},
                    {item:qsTr("Learned"), value:learned},
                    {item:qsTr("Mastered"), value:mastered}]
        }
        modelDatas = modelDatas
        judgeTitleLevel(mastered)
    }

    function judgeTitleLevel(mastered){
        for(var i = 0; i < Consts.lvUpCriteria.length; i++){
            if(mastered >= Consts.lvUpCriteria[i]){
                titleLv = i+1
            }else{
                break
            }
        }
        UserSettings.title = Consts.titles[titleLv]
    }

    function saveStudyInfoToUsageServer(deckName, news, learned, mastered){
        var gameRecordStr = appSettings.readSetting(AppKeys.gameRecords)
        if(typeof(gameRecordStr) == "undefined"){
            gameRecordStr = "{}"
        }
        if(typeof(gameRecordStr) == "object" ){
            /* In old design, appSettings.readSetting(AppKeys.gameRecords) returns an object. In this case,
            we should convert it to string first. In new design, this condition shouldn't be entered.*/
            gameRecordStr = JSON.stringify(gameRecordStr)
        }
        var gameRecords = JSON.parse(gameRecordStr)

        if(typeof(gameRecords[deckName]) == "undefined"){
            gameRecords[deckName] = {}
        }

        gameRecords[deckName].studyInfos = {
            news: news, learned: learned, mastered: mastered
        }
/*This code should be removed in the future*/
var tempStr = JSON.stringify(gameRecords)
//console.log("tempStr:", tempStr)
gameRecords = JSON.parse(tempStr.replace(/anki\//, ""))
//console.log("After replace anki/ : ", JSON.stringify(gameRecords) )
/*This code should be removed in the future*/

        appSettings.writeSetting(AppKeys.gameRecords, JSON.stringify(gameRecords))
    }

}

