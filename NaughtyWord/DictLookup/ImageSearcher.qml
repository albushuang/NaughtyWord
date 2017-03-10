import QtQuick 2.0
import ImageScraper 0.1
import com.glovisdom.UserSettings 0.1
import "googleImage.js" as GImage
import "vocabularyServer.js" as Server
import "qrc:/"

Item {
    signal foundImage(ListModel model);
    signal foundImageFromServer(ListModel model);
    property var modelFormat;
    property variant dataFromServer
    property alias model: googleImageResult
    // PRAGMA: search image by google & bing ==================================
    ImageScraper { id: iScraper
        property int start;
        property int number;
        onScraped: {
            for(var i=0;i<number && i<urls.length;i++) {
            //for(var i=start;i<number+start && i<urls.length;i++) {
                //var element = new modelFormat(tbUrls[i], urls[i], "");
                googleImageResult.append(modelFormat(tbUrls[i], urls[i], ""));
            }
            foundImage(googleImageResult);
        }
    }

    JSONListModel { id: googleImageJSON
        query: "$.responseData.results[*]"
        onJsonChanged: {
            for (var i=0; i< googleImageJSON.model.count; i++ ) {
                var tbUrlString = googleImageJSON.model.get(i).tbUrl;
                var urlString = googleImageJSON.model.get(i).url;
                //var element = new modelFormat(tbUrlString, urlString, "");
                googleImageResult.append(modelFormat(tbUrlString, urlString, ""));
            }
            foundImage(googleImageResult);
        }
        ListModel { id: googleImageResult }
    }
    function getResultModel() {
        return googleImageResult
    }

    function handleWordObjResult(obj){
        if(Object.keys(obj).length > 0){
            obj.sort(function (a,b){return a.count - b.count})
            if(!own.usingOtherKeyWord){ dataFromServer = obj}
            for(var i = 0; i< obj.length; i++){
                //var element = new modelFormat("", obj[i].imageURL, "");
                googleImageResult.insert(0, modelFormat("", obj[i].imageURL, ""))
            }
            foundImageFromServer(googleImageResult);
        }else{ if(!own.usingOtherKeyWord){dataFromServer = []}}
    }

    function search(key, criterion, start, number, searchFromServer, usingOtherKeyWord) {
        iScraper.setKeyAndRange(key+" "+criterion, start, number, UserSettings.searchForCommercial);
        iScraper.start = start;
        iScraper.number = number;
        googleImageJSON.source = GImage.googleSource(key, criterion, start, number);
        if(searchFromServer && start==0){
            own.usingOtherKeyWord = usingOtherKeyWord
            Server.getWordObj(key, handleWordObjResult)
        }
    }
    function clearImageModel() {
        googleImageResult.clear();
    }
    QtObject{id: own
        property bool usingOtherKeyWord: false
    }
}
