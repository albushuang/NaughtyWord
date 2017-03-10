import QtQuick 2.0
import FileDownloader 0.1

Item { id: root; visible: false
    property string deckPath

    property string fileId
    property string fileName
//step0: use link to get file name (title) in file metadata
//step1: use direct link to get final download link
//Step2: use final doanload link to download the file
    property int step: 0
//  Constant strings
    property string apiKey: "AIzaSyDEgRlJJ3aDLUoa5qAhlNjw0dtEZVZK570"
    property string apiGet: "https://www.googleapis.com/drive/v2/files/"
    property string directLink: "https://drive.google.com/uc?export=download&id="

    signal downloaded(string pathName, string fileName);
    signal downloadFailed(string error);

    Timer{id: guardTimer; interval: 1000000//Don't use guardTimer now, because we cannot properly handle
        //fileDownloader sending weird data (probably, previous file's data)
        onTriggered: {root.endAbnormally("Time out"+ interval/1000 + "sec")}
    }
    FileDownloader { id: fileDownloader
        onProgressing: {
            guardTimer.restart()
            handleProgressing(received, total);
        }
        onDownloaded: { handleDownloaded(); }
        onDownloadFailed: { handleDownloadFailed(); }
        function requireDownloader(path, fileName, url) {
            fileDownloader.storagePath = path;
            fileDownloader.fileName = fileName
            fileDownloader.fileUrl = url;
        }
    }

    function startDownloadBy(sharingUrl){
        init();
        guardTimer.restart();
        if(sharingUrl.indexOf("https://drive.google.com") == -1){
            endAbnormally(qsTr("Not a valid Google Drive link"));
            return
        }

        fileId = extractFileId(sharingUrl);
        var completeApiGet = apiGet + fileId + "?key=" + apiKey
        fileDownloader.requireDownloader("", "", completeApiGet);
    }

    function extractFileId(sharingUrl){
        if(sharingUrl.indexOf("https://drive.google.com/open?id=") != -1){
            var idx = sharingUrl.lastIndexOf("?id=") ;
            return sharingUrl.substr(idx + 4, sharingUrl.length - 1)
        }else if(sharingUrl.indexOf("https://drive.google.com/file/d/") != -1){
            var strArray = sharingUrl.split("/");
            for(var i =0; i< strArray.length; i++){ if(strArray[i] == "d") { return strArray[i+1]} }
        }else{
            console.assert(false, "Unexpected google drive link:" + sharingUrl)
        }

    }

    function init(){
        step = 0;
        fileId = "";
        fileName = "";
    }

    function handleDownloaded(){
        switch(step){
        case 0:
            try{
                step++;
                var httpRspStr = fileDownloader.downloadedDataString;
                var httpRspObj = JSON.parse(httpRspStr);
                // Cannot use httpRspObj["downloadUrl"] directly without Oauth
                fileName = httpRspObj["title"]
                if(fileName.indexOf(".kmr") == -1) {
                    //: The format of this file is invalid
                    endAbnormally(qsTr("The format of this file is invalid."));
                    return;
                }
                fileDownloader.requireDownloader("", "", directLink + fileId);
            }
            catch(err){
                console.log("step 0 error:", err)
                endAbnormally("Unknown error");
            }
            break;
        case 1:
            try{
                step++;
                httpRspStr = fileDownloader.downloadedDataString;
                var urlStart = httpRspStr.indexOf("https://doc");
                var urlEnd = httpRspStr.indexOf("\">here</A>")
                var downloadUrl = httpRspStr.slice(urlStart, urlEnd);
                if(urlStart == -1 || urlEnd == -1){
                    endAbnormally(qsTr("Unknown network problem"));
                    console.assert(false, "possiblly, google change their api. The response text is:" + httpRspStr)
                    return
                }
                fileDownloader.requireDownloader(deckPath ,fileName, downloadUrl );
            }catch(err){
                console.log("step 1 error:", err)
                endAbnormally("Unknown error");
            }
            break;

        case 2:
            guardTimer.stop();
            downloaded(fileDownloader.storagePath, fileDownloader.fileName);
            break;
        }
    }

    function endAbnormally(error){
        guardTimer.stop();
        downloadFailed(error);
    }

    function handleProgressing(received, total){/*leave handling to UI user*/}

    function handleDownloadFailed(){
        endAbnormally(qsTr("Unknown network problem"));
    }

}


