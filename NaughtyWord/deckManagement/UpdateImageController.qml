import QtQuick 2.0
import QtQuick.Controls 1.3
import DownloadAgent2Provider 0.1
import com.glovisdom.NWPleaseWait 0.1
import com.glovisdom.UserSettings 0.1
import FileDownloader 0.1
import "qrc:/DictLookup/vocabularyServer.js" as Server
import "qrc:/generalModel"
import "qrc:/gvComponent"
import "qrc:/../UIControls"

// TODO: %20 is converted to ' ', this should be considered in many cases, including filedownloader
Item { id: updater
    property string imageURL
    property string imageTBURL
    signal taskStopped(var updater)
    property var imageGetter
    property var theCard
    property DeckMedia dm
    property var cropInfo
    property bool speechDone
    property bool imageDone
    property bool finalResult : true
    property variant dataFromServer

    function getAudio(url) {
        if(url!="") {
            speechDone = false
            speechGetter.fileUrl = url
        } else {
            speechDone = true
            end(true)
        }
    }

    FileDownloader { id: speechGetter
        onDownloaded: {
            speechDone = true
            own.finalSpeechURL = fileUrl
            end(true)
        }
        onDownloadFailed: {
            speechDone = true
            end(false)
        }
        onNetworkUnavailable: {
            speechDone = true
            end(false)
        }
    }

    QtObject { id: own
        property int dbImageWidth: 512
        property int dbImageHeight: 512
        property string finalImageURL: ""
        property string finalSpeechURL: ""
        function redirected(org, red) {
            var o = speechGetter.convert(org)
            var i = speechGetter.convert(imageURL)
            if(o==i) {
                imageURL = red
            }
        }

        function compareUrl(org) {
            var o = speechGetter.convert(imageGetter.fileUrl)
            var i1 = speechGetter.convert(imageURL)
            var i2 = speechGetter.convert(imageTBURL)
            if(o!=i1 && o!=i2) {
                console.log("wrong urls:\n", o, "\n", i1, "\n", i2)
                return false;
            }
            return true
        }

        function dlOK() {
            if(compareUrl(imageGetter.fileUrl)) {
                imageDone = true
                finalImageURL = imageGetter.fileUrl;
                end(true);
            }
        }
        function dlFailed() {
            if(compareUrl(imageGetter.fileUrl)) {
                var o = speechGetter.convert(imageGetter.fileUrl)
                var i1 = speechGetter.convert(imageURL)
                if(o==i1) {
                    imageGetter.fileUrl = imageTBURL;
                } else {
                    finalImageURL = "";
                    imageDone = true
                    end(false);
                }
            }
        }
        function netIssue() {
            if(compareUrl(imageGetter.fileUrl)) {
                imageDone = true
                end(false)
            }
        }
        function disconnectAll() {
            imageGetter.onRedirected.disconnect(own.redirected)
            imageGetter.onDownloaded.disconnect(own.dlOK)
            imageGetter.onDownloadFailed.disconnect(own.dlFailed)
            imageGetter.onNetworkUnavailable.disconnect(own.netIssue)
            NWPleaseWait.visible=false
        }
    }

    Component.onCompleted: {
        imageGetter.onRedirected.connect(own.redirected)
        imageGetter.onDownloaded.connect(own.dlOK)
        imageGetter.onDownloadFailed.connect(own.dlFailed)
        imageGetter.onNetworkUnavailable.connect(own.netIssue)
        NWPleaseWait.visible = true;
        NWPleaseWait.message = ""
        NWPleaseWait.state = "running"
    }
    Component.onDestruction: {
        own.disconnectAll()
    }

    function setImageURL(url, tbUrl) {
        imageURL = url
        imageTBURL = tbUrl
        imageDone = false
        imageGetter.fileUrl = url
    }

    function end(result) {
        finalResult = finalResult && result
        if (speechDone && imageDone) {
            if(finalResult) {
                update(imageGetter, speechGetter, own.finalImageURL, own.finalSpeechURL)
                if(!UserSettings.autoDict && own.finalImageURL!=imageTBURL) {
                    Server.saveImageUrlToServer(theCard.word, own.finalImageURL, dataFromServer)
                }
            } else {
                console.log("network error while updating image!");
            }
            own.disconnectAll();
            taskStopped(updater)
        }
    }
    function update(imager, speecher, iurl, surl) {
        theCard.imageURL = iurl
        theCard.speechURL = surl
        var ret = imager.cropResizeImageWithReference(
             cropInfo[0],cropInfo[1],cropInfo[2],cropInfo[3],
             cropInfo[4],cropInfo[5],cropInfo[6],cropInfo[7],
             512, 512);
        var returns = ret.split(",");
        cropInfoForCard(theCard, returns);
        if(UserSettings.notesOnly==0) {
            dm.updateCardMedia(theCard, imager, speecher);
        } else {
            dm.updateCardNotes(theCard, imager, speecher);
        }

        dm.releaseCard(theCard)
    }
    function cropInfoForCard(card, returns) {
        card["orgX"] = parseInt(returns[1]);
        card["orgY"] = parseInt(returns[2]);
        card["Width"] = parseInt(returns[3]);
        card["Height"] = parseInt(returns[4]);
    }
}
