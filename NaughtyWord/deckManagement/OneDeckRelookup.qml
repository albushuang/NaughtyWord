import QtQuick 2.0
import QtMultimedia 5.5
//import AppSettings 0.1
import "qrc:/generalModel"
import "qrc:/../../UIControls"
import "qrc:/DictLookup"
//import "qrc:/NWDialog"
//import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/objectCreate.js" as Create
import "qrc:/DictLookup/gdicts.js" as GDict
import "qrc:/gvComponent"
//import com.glovisdom.UserSettings 0.1


Item { id: relookup

    property DictLookupView cview
    property DeckMedia deckMedia
    property ListModel speechList
    signal taskDone()

    Audio { id: speaker }

    function relookup(card) {
        own.card = card
        own.searchImage()
        own.searchSpeech()
    }
    function playAudio(index) {
        speaker.source = speechList.get(index).url
        speaker.play()
    }
    function otherKeyWordEnturned(inputs){
        own.imgController.search(inputs,false, true);
    }
    function addCard(iIndex, sIndex, newNotes, dummy) {
        var speechUrl
        if(speechList.count>0 &&
           sIndex >= 0 && sIndex<speechList.count) {
            speechUrl = speechList.get(sIndex).url
        } else { speechUrl = "" }

        own.card.notes = newNotes
        own.card.dummyWord = dummy[0]
        own.card.dummyNote = dummy[1]
        own.card.imgAccuracy = dummy[2]
        var properties = {
            width: controller.width/2,
            height: controller.height/3,
            imageGetter: own.imgController.imageBrowserGetImageGetter(),
            dm: deckMedia,
            theCard: own.card,
            dataFromServer: own.imgController.getDataFromServer()
        }
        var obj = Create.instantComponent(controller, "qrc:/deckManagement/UpdateImageController.qml", properties)
        obj.cropInfo = cview.getImageBrowser().reportCropInfo()
        obj.onTaskStopped.connect(own.updateCard)
        obj.setImageURL(own.imgController.imageBrowserGetURL(iIndex),
                        own.imgController.imageBrowserGetTB(iIndex))

        obj.getAudio(speechUrl)
    }
    function setDirectLink(text) {
        own.imgController.setDirectLink(text)
    }

    QtObject { id: own
        property ListModel speechListModel: speechList
        property var imgController
        property var pronSearcher
        property var card

        function searchImage() {
            imgController = Create.instantComponent(relookup,
                                                    "qrc:/DictLookup/ImageBrowserController.qml", {})
            imgController.setView(cview.getImageBrowser());
            imgController.search(card.word, true, false);
        }
        // after search and card updated, delete object
        function searchSpeech() {
            pronSearcher = Create.instantComponent(relookup, "qrc:/DictLookup/SearchSpeech.qml", {})
            pronSearcher.callback = updateToView
            pronSearcher.search(card.word)
            GDict.lookupGDict(card.word, function (text, textArray, pron) {
                pronSearcher.makeModel(pron, false);
                updateToView();
            });
        }

        function updateToView() {
            var pronFound = pronSearcher.getModel()
            var url = []
            for(var i=0;i<pronFound.count && i<3;i++) {
                url.push(pronFound.get(i)[pronSearcher.urlName])
            }
            var elements = cview.updateSpeechUrl(url);
            speechList.clear();
            for (i=0;i<elements.length;i++) {
                speechList.append(elements[i])
            }
        }

        function updateCard(updater) {
            updater.destroy();
            imgController.destroy()
            pronSearcher.destroy()
            taskDone();
        }
    }
    Component.onCompleted: {
        GDict.sim2Tra = function (cc) { return cc }
    }
}

