.pragma library
.import "qrc:/serverAPI/firebaseAPI.js" as API
.import com.glovisdom.DefinitionVendor 0.1 as DefVendor
var defVendor = DefVendor.DefinitionVendor

function saveUsageRecords(path, newData){
    API.saveData(path, newData)

}


/*Private functions*/

/*init works like component.onComplete*/
var init = API.setTargetSrv("https://"+defVendor.firebaseUrl+"/")
