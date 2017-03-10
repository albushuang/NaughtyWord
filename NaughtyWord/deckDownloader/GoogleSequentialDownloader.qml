import QtQuick 2.0
import "qrc:/../../UIControls"
GooglePublicLinkDownloader{
    property var dlLists
    property int currDlIdx: 0;
    property bool hasError: false
    signal startDlFile(string fileName)
    signal finishOneFile(string fileName)
    signal oneFileFailed(string fileName)
    signal allFinished()
    signal progressing(string fileName, real received, real total)

    function startDownload(downloadLists){
        dlLists = downloadLists
        startDlFile(dlLists[currDlIdx].name)
        var randIdx = Math.floor(Math.random()*dlLists[currDlIdx].dlUrlLists.length)
        startDownloadBy(dlLists[currDlIdx].dlUrlLists[randIdx])
        currDlIdx++;
    }

    onDownloaded: {
        finishOneFile(fileName)
        if(currDlIdx < dlLists.length){
            startDlFile(dlLists[currDlIdx].name)
            var randIdx = Math.floor(Math.random()*dlLists[currDlIdx].dlUrlLists.length)
            startDownloadBy(dlLists[currDlIdx].dlUrlLists[randIdx]);
            currDlIdx++;
        }else{
            allFinished(hasError)
        }
    }
    onDownloadFailed: {        
        console.assert(false, "download fail. Error:" + error +"\nfile:" + fileName)
        oneFileFailed(fileName)
        hasError = true
        if(currDlIdx < dlLists.length){
            startDlFile(dlLists[currDlIdx].name)
            var randIdx = Math.floor(Math.random()*dlLists[currDlIdx].dlUrlLists.length)
            startDownloadBy(dlLists[currDlIdx].dlUrlLists[randIdx]);
            currDlIdx++;
        }else{
            allFinished(hasError)
        }        
    }
    function handleProgressing(received, total){
        if(step == 2){
            progressing(fileName, received, total)
//            var totalStr = total != 0 ? qsTr(("/ " + total.toFixed(2) + "M ")) : "" ;
//            //: show users about received/total MB.
//            NWPleaseWait.message = qsTr( "%1M %2received...").arg(received.toFixed(2)).arg(totalStr);
        }
    }
}

