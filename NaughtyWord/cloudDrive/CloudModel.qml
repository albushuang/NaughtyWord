import QtQuick 2.0
import FileUploader 0.1
import FileDownloader 0.1
import QTDropboxQml 0.1
import AppSettings 0.1
import "CloudConst.js" as Consts
import "googleApi.js" as GgApi
import "../generalJS/appsettingKeys.js" as AppKeys
import com.glovisdom.DefinitionVendor 0.1

Item {id: root
    property string driveType
    property string viewMyDrive
    property string uploadFileUrl: ""

    onUploadFileUrlChanged: {
        var arr = uploadFileUrl.split("/")
        own.uploadFileName = arr[arr.length-1]
    }

    property ListModel myFileModel : ListModel { }
    property ListModel myFolderModel : ListModel { }
    property ListModel sharedFileModel : ListModel { }
    property ListModel sharedFolderModel : ListModel { }
    property alias popupModel: popupModel
    ListModel{id: popupModel
        Component.onCompleted: {
            append({id: 0, display: Consts.disSharingLink});
        }
    }
    property variant enumPopupDirection

    property string fileLists: "no file"

    signal tokenIsReady(string token)
    signal modelsReady()
    signal requestLogin(string authUrl)
    signal requestDialog(string text, string title, bool hasTwoBtn, bool hasInput, variant callback)
    signal requestPopup(variant popupModel, variant callback, int direction)
    signal reqeustWaiting(bool isOn, string text)
    signal goBack()

    signal downloaded(string pathName, string fileName)
    signal uploaded()
    signal progressing(int received, int total, bool isDL)
    signal downloadFailed(string error)
    signal uploadFailed(string error)

    CloudDriveSettings{id: cloudSettings}
    AppSettings{id: appSettings}

    function getRootId(myDrive){
        return myDrive ? own.myRootId : own.sharedRootId
    }

    function start(){
        fileListsChanged.connect(own.fillModels)
        own.getFileLists()
    }

    function handleSettingClicked(index, theItem){
        //When clicking setting, open popup first, and then handle later
        own.index = index
        own.modelItem = theItem
        requestPopup(popupModel, own.handlePopup, enumPopupDirection.up)
    }

    function handleFileClicked(index, theItem){
        //When clicking file, show confirmation (dialogue) and then download
        own.index = index
        own.modelItem = theItem
        var text = qsTr("Are you sure to download \"%1\"").arg(theItem.title.split(".")[0])
        requestDialog(text, Consts.titleDownload, true, false, own.download)
    }

    function handleUploadClicked(currFolderId){
        //When clicking upload btn, show confirmation (dialogue) and then upload
        own.currFolderId = currFolderId
        var text = qsTr("Are you sure to upload \"%1\"").arg(own.uploadFileName.split(".")[0])
        requestDialog(text, Consts.titleUpload, true, false, own.upload)
    }

    function handleGgAuthCodeUpaded(authCode){
        GgApi.queryTokenByCode(authCode, DefinitionVendor.ggClientID, DefinitionVendor.ggSecret)
    }

    function handleDropboxAuthFinished(){
        dbox.continueUnfinished()
    }

    function logoutModel(){
        if(driveType == Consts.googleDrive){
            logInView.url = "https://www.google.com/accounts/Logout"
            cloudSettings.ggToken = "";
            cloudSettings.ggRefreshToken = "";
        }
        else if(driveType == Consts.dropBox){
            logInView.url = "https://www.dropbox.com/logout"
            dbox.logout();
        }
        else{
            console.log("DriveType != googleDrive && DriveType != dropbox")
        }
        own.clearModels()
    }

    onTokenIsReady: { if(driveType == Consts.googleDrive){ GgApi.getFileLists() } }

    QTDropboxQml { id: dbox
        onRequestUserConsent: {
            requestLogin(authUrl);
        }
        onFileListChanged:{
            root.fileLists = dbox.fileList
        }
        onDownloaded:{ root.downloaded()}
        onUploaded:{
            root.uploaded()
            requestDialog(qsTr("Upload finished"), "", false, false, goBack)
        }
        onProgressing:{ root.progressing(received, total, true); }
        onLogoutFinished:{
            start();
        }
        onDbConnected: { reqeustWaiting(true, qsTr("Please wait...")) }
    }

    FileUploader{id: fileUploader   //Dropbox doesn't use updownloader
        onUploaded: {
            var item = JSON.parse(fileUploader.networkReplyMsg)
            var parentObj = {}
            if(thisModel.myFileModel.count != 0){
                parentObj = GgApi.composeParentObj(item.id, own.currFolderId,
                                 own.currFolderId == thisModel.getRootId(viewMyDrive))
            }
            GgApi.updateFileTitle(item.id, own.uploadFileName, parentObj)
            root.uploaded()
            requestDialog(qsTr("Upload finished"), "", false, false, goBack)
        }
        onProgressing: { root.progressing(received, total, false);  }
        onUploadFailed: {root.uploadFailed("upload fail:", fileUploader.networkReplyMsg)}
        onNetworkUnavailable: {console.assert(false, "network not available. Check previous upload")}
    }

    FileDownloader { id: fileDownloader
        onProgressing: { root.progressing(received, total, true); }
        onDownloaded: { root.downloaded(storagePath, fileName) }
        onDownloadFailed: {  root.downloadFailed("Download shouldn't fail.") }
        function requireDownloader(path, fileName, url) {
            fileDownloader.storagePath = path;
            fileDownloader.fileName = fileName
            fileDownloader.fileUrl = url;
        }
    }

    QtObject{id: own
        property string myRootId: ""   //A root id for my drive
        property string sharedRootId: ""   //A root id for sharing file
        property string permissionId: ""   //I am not sure, but it seems that there is only one permissionId for one user

        property int index
        property variant modelItem
        property variant currFolderId
        property string uploadFileName

        function getFileLists(){
            if(driveType == Consts.googleDrive){
                var result = GgApi.getTokenStatus()
                if(result.status == Consts.ggTokenValid){
                    GgApi.getFileLists()
                }else if(result.status == Consts.ggHasRefreshToken){
                    GgApi.queryTokenByRefresh(result.token, DefinitionVendor.ggClientID, DefinitionVendor.ggSecret);
                }else{  // result.status == Consts.ggNoRefreshToken
                    requestLogin("")
                }
            }else if(driveType == Consts.dropBox){
                dbox.start()
            }else{
                console.assert(false, "Now, we only support google drive and dropbox.")
            }
        }

        function fillModels(){
            if(fileLists != ""){
                myRootId = ""
                sharedRootId = ""
                permissionId = ""
                clearModels()
                if(driveType == Consts.googleDrive){
                    ggFillModel(fileLists)
                }else if(driveType == Consts.dropBox){
                    dboxFillModel(fileLists)
                }
                fileLists = ""
                modelsReady()
            }else{
                modelsReady()
            }
        }

        function removeLinefeed(str) {
            return str.replace(/\n/g, "")
        }

        function ggFillModel(fileLists){
            fileLists = removeLinefeed(fileLists)
            //console.log("to parse:", fileLists)
            var items = JSON.parse(fileLists).items
            var folderLists = []
            //console.log(items, items.length)
            // Parse all folder first, so we dont have to parse whole fileLists for finding parent
            for(var i = 0; i < items.length; i++){
                if(items[i].mimeType.indexOf("apps.folder") != -1){
                    folderLists.push(items[i])
                    //console.log("foler:", items[i].title)
                }
            }

            for(i = 0; i < items.length; i++){
                //console.log("parsing:", items[i].title)
                var title = items[i].title
                if(permissionId == "" && items[i].owners[0].isAuthenticatedUser){
                    permissionId = items[i].owners[0].permissionId
                }

                if(title.indexOf(".kmr") != -1 && items[i].explicitlyTrashed == false){
                    for(var j = 0 ; j < items[i].parents.length; j++){
                        var parentTitle = own.findParentTitleUntillRoot(folderLists, items[i].parents[j])
                        var isShared = items[i].userPermission.role != "owner"
                        var parentId = isShared && parentTitle == "root" ? getRootId(false) : items[i].parents[j].id
                        var fillingModel = isShared ? sharedFileModel : myFileModel
                        fillingModel.append({"title": title,
                                             "id": items[i].id,
                                             "parentTitle": parentTitle,
                                             "parentId": parentId,
                                             "downloadUrl": items[i].downloadUrl
                                         })

                    }
                    if(items[i].parents.length == 0){
                        parentTitle = own.findParentTitleUntillRoot(folderLists, (function (){return})())
                        isShared = true
                        parentId = getRootId(false)
                        fillingModel = sharedFileModel
                        fillingModel.append({"title": title,
                                             "id": items[i].id,
                                             "parentTitle": parentTitle,
                                             "parentId": parentId,
                                             "downloadUrl": items[i].downloadUrl
                                         })
                    }
                }
            }

            for(i = 0; i < folderLists.length; i ++){
                if(folderLists[i].hasKmrj){
                    isShared = folderLists[i].userPermission.role != "owner"

                    parentId = isShared && folderLists[i].parentTitle == "root" ?
                                getRootId(false) : folderLists[i].parents[0].id
                    fillingModel = isShared ? sharedFolderModel : myFolderModel
                    fillingModel.append({  "title": folderLists[i].title,
                                           "id": folderLists[i].id,
                                           "parentTitle": folderLists[i].parentTitle,
                                           "parentId": parentId,
                                           "downloadUrl": folderLists[i].downloadUrl})
                }
            }

        }

        function dboxFillModel(fileList){
            var items = fileList.split("\n")
            for(var i = 0; i < items.length; i++){
                var pathArr = items[i].split("/")
                for(var j = 1; j < pathArr.length; j++){    //j=0 is always empty
                    if(j == pathArr.length -1){
                        var myFillModel = myFileModel
                    }else{
                        myFillModel = myFolderModel
                    }
                    if(cloudView.findModelItemByID(own.getVirtualId(pathArr, j)).found == false){
                        myFillModel.append({ "title": pathArr[j],
                                             "id": own.getVirtualId(pathArr, j),
                                             "parentTitle": j == 1 ? "root": pathArr[j-1],
                                             "parentId": j == 1 ? Consts.fakeRootId: own.getVirtualId(pathArr, j - 1),
                                             "downloadUrl": "items[i].downloadUrl"
                                         })
                    }
                }
            }

        }

        function clearModels(){
            myFileModel.clear()
            myFolderModel.clear()
            sharedFileModel.clear()
            sharedFolderModel.clear()
        }

        //Once we find a .kmrj, use recursive to mark all folder as hasKmrj until find a root
        function findParentTitleUntillRoot(folderLists, parent){
            //in ”共我公用項目“, there is no root parent. In this case, root parent is null(undefined)
            if(typeof(parent) == "undefined"){
                if(sharedRootId == ""){ sharedRootId = Consts.fakeRootId}
                return "root"
            }

            if(parent.isRoot ){
                if(myRootId == ""){ myRootId = parent.id}
                return "root"
            }

            for(var i = 0; i < folderLists.length; i++){
                if(folderLists[i].id == parent.id){
                    folderLists[i].hasKmrj = true
                    if(typeof(folderLists[i].parentTitle) == "undefined"){
                        folderLists[i].parentTitle = findParentTitleUntillRoot(folderLists, folderLists[i].parents[0])
        //                var parentId = folderLists[i].shared && folderLists[i].parentTitle == "root" ?
        //                            sharedRootId : folderLists[i].parents[0].id
        //                folderLists[i].parentId = parentId
                    }

                    return folderLists[i].title
                }
            }
        }

        function getVirtualId(pathArr, index){
            return pathArr.slice(0,index + 1).join("/")

        }

        function download(){
            reqeustWaiting(true, qsTr("Please wait..."))

            if(driveType == Consts.googleDrive){
                fileDownloader.requireDownloader(appSettings.readSetting(AppKeys.pathInSettings),
                            modelItem.title, modelItem.downloadUrl + "&access_token=" + GgApi.token );
            }else{
                dbox.fileName = modelItem.title
                dbox.storagePath = appSettings.readSetting(AppKeys.pathInSettings)
                dbox.download(modelItem.id)
            }
        }

        function upload(){
            reqeustWaiting(true, qsTr("Please wait..."))
            if(driveType == Consts.googleDrive){
                fileUploader.filePath = uploadFileUrl
                fileUploader.uploadUrl = GgApi.getUploadUrl()
            }else{
                var dropboxFilePath = (currFolderId == Consts.fakeRootId ?
                                      "" : currFolderId) + "/" + uploadFileName
                dbox.upload(uploadFileUrl, dropboxFilePath)
            }
        }

        function handlePopup(id, index){
            switch (id) {
            case Consts.idSharingLink:
                if(driveType == Consts.googleDrive){
                    var sharedLink  = GgApi.requestSharedLink(modelItem.id)
                    clipboard.text = sharedLink
                    clipboard.selectAll();clipboard.copy()
                }else if(driveType == Consts.dropBox){
                    sharedLink = dbox.requestSharedLink(modelItem.id)
                }
                requestDialog(sharedLink, Consts.titleLinkCopied, false, false, function(){return})
                break;
            }
        }

    }
}

