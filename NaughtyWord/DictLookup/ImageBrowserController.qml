import QtQuick 2.0
import FileDownloader 0.1
import GlobalBridgeOfImageProvider 0.1
import DownloadAgent2Provider 0.1
import com.glovisdom.UserSettings 0.1
import "qrc:/../../UIControls"

// TODO: when redirecting, the return url is changed.
// TODO: when multiple requests are applied..
Item { id: controller
    property var qImageHelpMap: [];
    property ImageBrowser2 iBrowser;
    property int imagePerRequest: 6
    property int imageCount: 0
    property int extraKeyIdx: 0
    property string key
    property var extraKey: ["", "photo ", "cartoon "];
    signal needMoreImage()

    QtObject{id: own
        property bool useExtraKey: true
    }

    ImageSearcher { id: dictionary }
    //onIBrowserChanged: { dictionary.modelFormat = iBrowser.imageElement; }

    BridgeOfImageProvider { id: bridge }
    DownloadAgent2Provider { id: filedownload
        onImageReady: { downloadedToImageProvider(source, true);}
        onImageInvalid: { downloadedToImageProvider(source, false);}
        onRedirected: { recordNewUrl(original, redirect); }
        Component.onCompleted: { setMediaBox(bridge.self()); }
    }
    Component.onCompleted: {
        dictionary.onFoundImage.connect(updateImage);
        dictionary.onFoundImageFromServer.connect(resetIndex);
    }
    Component.onDestruction: {
        // clear user downloaded image fro media provider
        releaseImages()
        cleanArray(qImageHelpMap)
    }

    function setView(view) {
        iBrowser = view;
        iBrowser.delegator = controller;
        iBrowser.model = dictionary.model
        dictionary.modelFormat = iBrowser.imageElement
    }

    // public function
    function search(inputs, useExtraKey, usingOtherKeyWord) {
        own.useExtraKey = useExtraKey
        cleanControls();
        key = inputs;
        dictionary.search(inputs, "", 0, imagePerRequest,
                          UserSettings.autoDict==0, usingOtherKeyWord);
    }

    function setSynonym(syn) {
        extraKey.push.apply(extraKey, syn);
    }

    function imageBrowserGetTB(index) {
        var model = dictionary.getResultModel();
        return model.get(index)[iBrowser.tbUrlField];
    }
    function imageBrowserGetURL(index) {
        var model = dictionary.getResultModel();
        var agentUrl = model.get(index)[iBrowser.agentField];
        if(agentUrl.slice(0, 17)=="image://download/") agentUrl = agentUrl.slice(17)
        else agentUrl = getPossibleURL(index)
        return agentUrl;
    }

    function getPossibleURL(index) {
        var url = ""
        for (var i=0;i < qImageHelpMap.length; i++) {
            if (qImageHelpMap[i].idx == index) {
                url = qImageHelpMap[i].redirect
                if(url=="") url = qImageHelpMap[i].source
                break
            }
        }
        return url
    }
    
    function getDataFromServer(){
        return dictionary.dataFromServer
    }

    function imageBrowserGetImageGetter() {
        return filedownload
    }

    // PRAGMA: delegation
    function imageBrowserSwipeFromLeft() { }
    function imageBrowserSwipeFromRight() { testIndexAndGetMoreIfNecessary(); }
    function imageBrowserBtnLeftClicked() { }
    function imageBrowserBtnRightClicked() { testIndexAndGetMoreIfNecessary(); }
    function imageBrowserNeedAgent(source, idx) {
        filedownload.setFileUrl(source);
        qImageHelpMap.push({source: filedownload.fileUrl, idx: idx, redirect: ""});
    }
    function downloadedToImageProvider(source, valid) {
        var orgSource = getRequestIDAndUpdate(source)
        var model = dictionary.getResultModel();
        var index = getNewIndex(orgSource, false)
        if(index<0) {
            console.warn("image source not found!")
            getNewIndex(orgSource, true)
            return
        }
        var item = model.get(index)
        item[iBrowser.agentField] = valid ? "image://download/" + source : "qrc:/pic/notSupported.png"
        item[iBrowser.urlField] = source
        iBrowser.setAgentUrl(item[iBrowser.agentField], index);
    }
    function getNewIndex(orgSource, log) {
        var model = dictionary.getResultModel();
        if(log) console.log("org:", orgSource)
        for(var i=0;i<model.count;i++) {
            var comp = filedownload.convert(model.get(i)[iBrowser.urlField])
            if(log) console.log("cm0:", comp, "\nqml: cm1:", model.get(i)[iBrowser.urlField])
            if(comp==orgSource) {
                return i;
            }
        }
        return -1
    }
    function tbError(imageItemThumbNail, tbUrl) { }

    // private function
    function updateImage(model) {
//        iBrowser.setModel(model);
        iBrowser.updateIndex();
    }

    function resetIndex(model){
        iBrowser.resetIndex()
    }

    function testIndexAndGetMoreIfNecessary() {
        if (iBrowser.isLastImage()) {
            needMoreImage()
            if(own.useExtraKey){
                extraKeyIdx++
                extraKeyIdx = (extraKeyIdx == extraKey.length) ? 0 : extraKeyIdx
                imageCount += extraKeyIdx == 0 ? imagePerRequest : 0;
                dictionary.search(key, extraKey[extraKeyIdx],
                                       imageCount, imagePerRequest, false, false);
            }else{
                imageCount += imagePerRequest
                dictionary.search(key, "", imageCount, imagePerRequest, false, false);
            }
        }
    }

    function getRequestIDAndUpdate(source) {
        for (var i=0;i < qImageHelpMap.length; i++) {
            if (qImageHelpMap[i].source == source || qImageHelpMap[i].redirect == source) {
                var ret = qImageHelpMap[i].source
                qImageHelpMap[i].source = source
                return ret
            }
        }
        return source
    }

    function recordNewUrl(src, tar) {
        for (var i=0;i < qImageHelpMap.length; i++) {
            if (qImageHelpMap[i].source == src) {
                qImageHelpMap[i]["redirect"] = tar;
            }
        }
    }

    function releaseImages() {
        for (var i=0;i < qImageHelpMap.length; i++) {
            bridge.removeFromMediaBox(qImageHelpMap[i].source);
        }
    }

    function cleanArray(array) {
        array = [];
        gc();
    }

    function clearLocalVariables() {
        imageCount = 0;
        extraKeyIdx = 0;
        while(extraKey.length>3) { extraKey.pop(); }
    }

    function cleanControls() {
        releaseImages()
        cleanArray(qImageHelpMap)
        dictionary.clearImageModel()
        //iBrowser.updateIndex()
        iBrowser.resetIndex()
        clearLocalVariables()
    }

    // for internal use only
    function setDirectLink(link) {
        cleanControls();
        var element = new iBrowser.imageElement("", link, "");
        var model = dictionary.getResultModel();
        model.append(element);
        iBrowser.updateIndex();
    }
}

