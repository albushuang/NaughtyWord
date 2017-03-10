.pragma library
.import "qrc:/serverAPI/firebaseAPI.js" as API
.import com.glovisdom.DefinitionVendor 0.1 as DefVendor
var defVendor = DefVendor.DefinitionVendor


//TODO: User might choose improper picture. (possible solution: 1, remember the user and block it.
//TODO: 2, analyze the image (or imageURL to know if image is weird)

function getWordObj(word, callback) {
    API.getData("words/" + word, callback)
}

function saveWordObj(word, dataObj){
    API.saveData("words/" + word, dataObj)
}

function saveImageUrlToServer(word, imageURL, dataFromServer){
/*If a user addCard many times without recheck dictionary, only the last imageURL will be
 saved in server because dataFromServer is not modified.*/
    try {
        if(Object.keys(dataFromServer).length <= 0){
            API.saveData("words/" + word , {0: {count: 1, imageURL: imageURL}})
        }else{
            var isFound = false
            for(var i = 0; i < dataFromServer.length; i++){
                if(imageURL == dataFromServer[i].imageURL){
                    isFound = true
                    API.saveData("words/" + word + "/" + i.toString() + "/count", ++dataFromServer[i].count)
                }
            }
            if(!isFound){
                API.saveData("words/" + word + "/" + dataFromServer.length.toString(),
                             {count: 1, imageURL: imageURL})
            }
        }
    }
    catch(err) {
        console.log("saveImageUrlToServer failed")
    }
}

function getWords(callback) {
    API.getData("words", callback)
}

/*init works like component.onComplete*/
var init = API.setTargetSrv("https://"+defVendor.firebaseUrl+"/")

