import QtQuick 2.0
import DictionaryLookup 0.1
//import SearchSpeech 0.1
import ImageScraper 0.1
import SDictLookup 0.1
import "gdicts.js" as GDict
import "wiktionary.js" as Wiki
import "googleImage.js" as GImage
import "../generalJS/character.js" as Char
import "../generalJS/appsettingKeys.js" as AppKeys


Item { id: mmDict
    property bool localDictionary: false
    property string noteID: GDict.noteID
    property string phoneticID: GDict.phoneticID
    property string messageID: GDict.messageID
    property string language
    signal lookedUp(variant result);
    signal foundMeaning(string source, variant textArray);
    signal foundPron(ListModel model);

    // PRAGMA: search in dictionary for definitions =====================
    DictLookUp { id: gdictAndChinese
        maxResult: 15;
        onSearchDone: {
            lookedUp(searchResult);
        }
    }
    // should make this dynamic...
    SDictLookUp { id: sdict
        maxResult: 15;
        onSearchDone: {
            lookedUp(searchResult);
        }
        Component.onCompleted: {
            var dictSetting = appSettings.readSetting(AppKeys.defaultDictionary);
            if (dictSetting!="") {
                if (sdict.setDictPath(dictSetting)) { localDictionary = true; }
            }
        }
    }
    SearchSpeech { id: sSeeker
        callback: spSeekDone
    }

    function checkResult(key, callback) {
        if(Char.isASCII(key, true)) {
            if(localDictionary) {
                return callback(key);
            } else {
                networkResult(key);
                return key;
            }
        }
        return callback(key);
    }

    function networkResult(key) {
        GDict.lookupGDict(key, function (source, textArray, pron, notFound) {
            if(notFound) {
                Wiki.getWikiExplanation(key, function(text){
                    var obj = { type: noteID, translation: text};
                    var source = text=="" ? "" : qsTr("source：wiktionary")
                    foundMeaning(source, [obj]);
                });
            } else {
                foundMeaning(source, textArray);
                sSeeker.makeModel(pron, false);
                if(pron.length!=0) { foundPron(sSeeker.getModel()); }
            }
        });
    }
    function setSearchKey(key) {
        if(localDictionary && Char.isASCII(key, true)) {
            sdict.searchKey = key;
        } else {
            gdictAndChinese.language = language
            gdictAndChinese.searchKey = key;
        }
    }
    function moreResult(key) {
        if(localDictionary && Char.isASCII(key, true)) {
            sdict.moreResult = true;
        } else {
            gdictAndChinese.moreResult = true;
        }
    }

    // PRAGMA: search speech by audio sites ============================
    QtObject { id: own
        function convertChinese() {
            if(language=="sc") { GDict.sim2Tra=function(cc) {return cc} }
            else {
                var component = Qt.createComponent("qrc:/DictLookup/Sim2Tradition.qml")
                GDict.sim2Tra = component.createObject(mmDict, {}).traditionalized;
            }
        }
    }

    Component.onCompleted: {
        own.convertChinese()
    }

    function spSeekDone(model) {
        foundPron(model);
    }


    function searchPron(key) {
        sSeeker.clearModel()
        sSeeker.search(key)
        if(localDictionary) {
            GDict.lookupGDict(key, function (text, textArray, pron) {
                sSeeker.makeModel(pron, false);
                if(pron.length!=0) { foundPron(sSeeker.getModel()); }
            });
        }
    }

    function pronUrl(index) {
        return sSeeker.getModel().get(index).url;
    }
}
