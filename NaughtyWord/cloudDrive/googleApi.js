var token = ""

function getTokenStatus(){
    token = cloudSettings.ggToken
    if(token != "" && typeof(token) != "undefined"){
        var now = new Date();
        var expiredTime = cloudSettings.ggTokenExpiredTime
        if(expiredTime - now.valueOf() > 0){
            return {status: Consts.ggTokenValid, token: token}
        }else{
            var refreshToken = cloudSettings.ggRefreshToken
            return {status: Consts.ggHasRefreshToken, token: refreshToken}
        }
    }else{
        return {status: Consts.ggNoRefreshToken, token: ""}
    }
}

function composeRequestTokenUrl(authCode, clientID, secret){
    var tokenUrl = "https://www.googleapis.com/oauth2/v3/token"
    tokenUrl += "?code=" + authCode
    tokenUrl += "&client_id=" + clientID //Consts.ggClientID
    tokenUrl += "&client_secret=" + secret //Consts.ggSecret
    tokenUrl += "&redirect_uri=" + Consts.ggRedirectUri
    tokenUrl += "&grant_type=authorization_code"
//    console.log("tokenUrl:", tokenUrl)
    return tokenUrl
}

function queryTokenByCode(authCode, clientID, secret) {
    var tokenUrl = composeRequestTokenUrl(authCode, clientID, secret)
    var xhr = new XMLHttpRequest;

    xhr.open("POST", tokenUrl);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            try {
//                console.log("use auth code response:", xhr.responseText)
                var response = JSON.parse(xhr.responseText);
                if(typeof(response.access_token) != "undefined" ){
                    var expiredTime = new Date();
                    expiredTime.setSeconds(expiredTime.getSeconds() + response.expires_in )
                    cloudSettings.ggTokenExpiredTime = expiredTime.valueOf()
                    cloudSettings.ggToken = response.access_token
                    cloudSettings.ggRefreshToken = response.refresh_token
                    token = response.access_token
                    tokenIsReady(response.access_token)
                }else{
                    console.assert(false, "error:", response.error, " error_description:", response.error_description)
                }
            }
            catch (err) {
                console.log("token request by code error:"+err)
            }
        }
    }
    xhr.send();
}

function composeRefreshTokenUrl(refreshToken, clientID, secret){
    var tokenUrl = "https://www.googleapis.com/oauth2/v3/token"
    tokenUrl += "?client_id=" + clientID //Consts.ggClientID
    tokenUrl += "&client_secret=" + secret //Consts.ggSecret
    tokenUrl += "&refresh_token=" + refreshToken
    tokenUrl += "&grant_type=refresh_token"
//    console.log("tokenUrl:", tokenUrl)

    return tokenUrl
}

function queryTokenByRefresh(refreshToken, clientID, secret) {
    var tokenUrl = composeRefreshTokenUrl(refreshToken, clientID, secret)
    var xhr = new XMLHttpRequest;

    xhr.open("POST", tokenUrl);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            try {
//                console.log("refresh token response:", xhr.responseText)
                var response = JSON.parse(xhr.responseText);
                if(typeof(response.access_token) != "undefined" ){
                    var expiredTime = new Date();
                    expiredTime.setSeconds(expiredTime.getSeconds() + response.expires_in )
                    cloudSettings.ggTokenExpiredTime = expiredTime.valueOf()
                    cloudSettings.ggToken = response.access_token
                    token = response.access_token
                    tokenIsReady(response.access_token)
                }else{
                    console.log("Refresh token fail. Error:", response.error, " error_description:", response.error_description)
                    console.log("Try user consense again (log-in)")
                    logInView.startLogIn("")
                }
            }
            catch (err) {
                console.log("token request by refresh error:"+err)
            }
        }
    }
    xhr.send();
}

function getFileLists(){
//TODO Need to handle if someone has files more than 1000
    var listApi = "https://www.googleapis.com/drive/v2/files?access_token=" + token + "&maxResults=1000"
    var xhr = new XMLHttpRequest;

    xhr.open("Get", listApi);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            try {
//                console.log("File lists:", xhr.responseText)
                var response = JSON.parse(xhr.responseText);
                if(typeof(response.kind) != "undefined" ){
                    root.fileLists = xhr.responseText
                }else{
                    console.log("error:", response.error, " code:", response.code, " message:", response.message)
                    logInView.startLogIn("")
                }
            }
            catch (err) {
                console.log("get fileLists error:"+err)
            }
        }
    }
    xhr.send();
}

function getUploadUrl(){
    return "https://www.googleapis.com/upload/drive/v2/files?uploadType=media&access_token=" + token
}

function putOrPostHttpWithBody(method, url, body){
    var xhr = new XMLHttpRequest;
    xhr.open(method, url);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            try {
//                console.log("Response:", xhr.responseText)
            }
            catch (err) {
                console.log("Put or Post request error:"+err)
            }
        }
    }

    xhr.setRequestHeader("Content-type", "application/json");
    xhr.setRequestHeader("Content-length", body.length);
    xhr.send(body);
}

function updateMetadata(fileId, metadata){
    var url = "https://www.googleapis.com/drive/v2/files/" + fileId + "?access_token=" + token
    //    console.log("update title URL:", url)

    putOrPostHttpWithBody("PUT", url, metadata)
}


function updateFileTitle(fileId, fileTitle, parentObj){    
    var metadataObj
    if(typeof(parentObj.kind) != "undefined"){
        metadataObj = {title: fileTitle, parents:[parentObj]}
    }else{
        metadataObj = {title: fileTitle}
    }

    var str = JSON.stringify(metadataObj)
//    console.log("str:", str, " str length:", str.length)

    updateMetadata(fileId, str)
}


function composeParentObj(currentId, parentId, isRoot){
    return {
        "kind":"drive#parentReference",
        "id":parentId,
        "selfLink":"https://www.googleapis.com/drive/v2/files/" + currentId + "/parents/" + parentId,
        "parentLink":"https://www.googleapis.com/drive/v2/files/" + parentId,
        "isRoot":isRoot
    }
}

function updatePermission(fileId, permission){
    var url = "https://www.googleapis.com/drive/v2/files/" + fileId + "/permissions" + "?access_token=" + token

    putOrPostHttpWithBody("POST", url, permission)
//
}

function requestSharedLink(fileId){
    var permissionObj = {
        "role":"reader",
        "type":"anyone"
    }
//    var metadataObj = {"userPermission": permissionObj/*, "shared": true*/}

    updatePermission(fileId, JSON.stringify(permissionObj))

    var downloadUrl = "https://drive.google.com/file/d/" + fileId + "/view?usp=sharing"
    return downloadUrl
}
