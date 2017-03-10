import QtQuick 2.0
import QtQuick.Controls 1.3
import FileDownloader 0.1
import DownloadAgent2Provider 0.1
import "../generalModel"

Item { id: saveCardModel
    signal imageTaskOK(string url);
    signal speechTaskOK(string url);
    signal imageTaskFailed(string url);
    signal speechTaskFailed(string url);
    signal imageTaskNetIssue(string url);
    signal speechTaskNetIssue(string url);
    property var imageGetter

    FileDownloader { id: speechGetter
        onDownloaded: {
            speechTaskOK(fileUrl);
        }
        onDownloadFailed: {
            speechTaskFailed(fileUrl);
        }
        onNetworkUnavailable: {
            speechTaskNetIssue(fileUrl);
        }
    }

    function setImage(url) {
        imageGetter.setFileUrl(url);
    }

    function setSpeech(url) {
        speechGetter.fileUrl = url;
    }

    // TODO: how to make sure current image and speech are the ones user wants to add?
    function addCard(deckMedia, card, userDeck, cropInfo, imageWidth, imageHeight) {
        var deckOld = deckMedia.getDeck();
        if(deckOld!=userDeck) { deckMedia.setDeck(userDeck); }
        if (!imageGetter.resizeImage(imageWidth, imageHeight)) { return false; }
        var ret = imageGetter.cropResizeImageWithReference(
                    cropInfo[0], cropInfo[1], cropInfo[2], cropInfo[3],
                    cropInfo[4], cropInfo[5], cropInfo[6], cropInfo[7],
                    imageWidth, imageHeight)
        var returns = ret.split(",");
        if(returns[0]=="-1") { return false; }
        own.cropInfoForCard(card, returns);
        deckMedia.addOrReplace(card, imageGetter, speechGetter);
        if(deckOld!=userDeck) { deckMedia.setDeck(deckOld); }
        return true;
    }
    QtObject { id: own
        function cropInfoForCard(card, returns) {
            card["orgX"] = parseInt(returns[1]);
            card["orgY"] = parseInt(returns[2]);
            card["Width"] = parseInt(returns[3]);
            card["Height"] = parseInt(returns[4]);
        }
    }

    function signalDLOK(fileUrl) {
        imageTaskOK(imageGetter.fileUrl);
    }
    function signalDLFailed(fileUrl) {
        imageTaskFailed(imageGetter.fileUrl);
    }
    function signalNetworkFailed(fileUrl) {
        imageTaskNetIssue(imageGetter.fileUrl)
    }
    Component.onCompleted: {
        if(typeof(imageGetter)!="undefined") {
            imageGetter.onDownloaded.connect(signalDLOK)
            imageGetter.onDownloadFailed.connect(signalDLFailed)
            imageGetter.onNetworkUnavailable.connect(signalNetworkFailed)
        }
    }
    Component.onDestruction: {
        imageGetter.onDownloaded.disconnect(signalDLOK)
        imageGetter.onDownloadFailed.disconnect(signalDLFailed)
        imageGetter.onNetworkUnavailable.disconnect(signalNetworkFailed)
    }
}
