.pragma library


/*If you don't understand the following code, you can read document:
https://www.firebase.com/docs/rest/guide/saving-data.html*/

function setTargetSrv( url){
    targetServerUrl = url
}

function saveData(path, dataObj){
    xhRequest("PUT", composeUrl(path), dataObj)
}

/*Update specific children at a location without overwriting existing data.
However, qml doesn't support this method (PATCH)*/
//function updateData(path, dataObj){
//    xhRequest("PATCH", composeUrl(path), dataObj)
//}

function removeData(path){
    xhRequest("DELETE", composeUrl(path))
}

/*callback will received dataObj as input argument*/
function getData(path, callback){
    xhRequest("GET", composeUrl(path), {}, callback)
}

//TODO add authetication

function composeUrl(path){
    return targetServerUrl + path + ".json"
}

function xhRequest(method, url, dataObj, callback){
    var xhr = new XMLHttpRequest();

    xhr.open(method, url);
    xhr.onreadystatechange = function() {
      if (xhr.readyState == XMLHttpRequest.DONE) {
          try {
//              console.log("Response:", xhr.responseText)
              var responseError = false
              if(xhr.responseText.indexOf("\"error\"") != -1){
                  responseError = true
                  console.assert(false, "response error:" + xhr.responseText)
              }
              if(typeof(callback) != "undefined"){
                  if(typeof(xhr.responseText) != "undefined" && xhr.responseText != "null"
                      && xhr.responseText != "" && !responseError){
                      callback(JSON.parse(xhr.responseText), true)
                  }else if(xhr.responseText == ""){
                      callback({}, false)
                  }else{
                      callback({}, true)
                  }
              }
          }
          catch (err) {
              console.assert(false, "unexpected error:"+err, "\nresponse txt:",xhr.responseText)
          }
      }

    }

    if(typeof(dataObj) == "undefined" || (typeof(dataObj) == "object" && Object.keys(dataObj).length == 0)){
        xhr.send();
    }else{
//        console.log("dataObj:",JSON.stringify(dataObj))
        xhr.send(JSON.stringify(dataObj));
    }
}

var targetServerUrl = ""
