.pragma library
.import "qrc:/serverAPI/firebaseAPI.js" as API
.import "scoreConsts.js" as Consts
.import com.glovisdom.UserSettings 0.1 as USettings
.import com.glovisdom.DefinitionVendor 0.1 as DefVendor

var getRecordCallback
var maxNumOfRecords = 50
var userSettings = USettings.UserSettings
var defVendor = DefVendor.DefinitionVendor

function getWholeRecords(keys, callback) {
    getRecordCallback = callback

//    console.log("path", preparePath(keys))
    API.getData(prepareRecordPath(keys), sortAndCallback)
}

/*Notice1: prevRecords should have been sorted by score already. So prevRecords is not exactly
the same with the records in server. That's why there is a field, "serverIdx"*/
/*Notice2: In order to prevent access server too often, we locally modify prevRecords and
return to caller. So the caller doesn't have to query server data again to get updated result*/
function updateRecords(keys, prevRecords, newRecord){
    var replacedIdx = findIdxOfReplacedRecord(prevRecords, newRecord)
    var isScoreHighEnough = false

    if(replacedIdx != -1){  /*Found this player's record => replace it if new score is higher*/
        if(newRecord.score > prevRecords[replacedIdx].score){
            isScoreHighEnough = true
            newRecord.serverIdx = prevRecords[replacedIdx].serverIdx
            prevRecords[replacedIdx] = newRecord
        }
    }else{
        if( prevRecords.length < maxNumOfRecords){
            isScoreHighEnough = true
            newRecord.serverIdx = prevRecords.length
            prevRecords.push(newRecord)
        }else{
            if(newRecord.score > prevRecords[maxNumOfRecords - 1].score ){
                isScoreHighEnough = true
                newRecord.serverIdx = prevRecords[maxNumOfRecords - 1].serverIdx
                prevRecords[maxNumOfRecords - 1] = newRecord
            }
        }
    }
    if(isScoreHighEnough){
        newRecord.playedTime = (new Date()).valueOf()
        newRecord.uuid = userSettings.uuid
        var path = prepareRecordPath(keys) + "/" + newRecord.serverIdx.toString()
        API.saveData(path, newRecord)
    }

    prevRecords.sort(function (a,b){//return a - b ==> ASC
        return (a.score != b.score) ? (b.score - a.score) : (a.playedTime - b.playedTime)
    })

    return prevRecords
}

function saveDeckName(keys, deckName){
    API.saveData(preparePath(keys), {deck: deckName } )
}

/*Private functions*/
function sortAndCallback(records, isServerAlive){
    if(Object.keys(records).length > 0){        
        records.sort(function (a,b){//return a - b ==> ASC
            return (a.score != b.score) ? (b.score - a.score) : (a.playedTime - b.playedTime)
        })
    }else{
        records = []
    }

    getRecordCallback(records, isServerAlive)
}

function prepareRecordPath(keys){
    return preparePath(keys) + "/records"
}

function preparePath(keys){
    var path = ""
    if(keys.length > 0){
        path += keys[0]
        for(var i = 1; i < keys.length; i++){
            path += "/" + keys[i]
        }
    }
    return path
}


function findIdxOfReplacedRecord(prevRecords, newRecord){
/* When UUID is the same, replace the record with the same name or replace the record
has lowest score when this uuid reach maximum acceptable record number. */
    var count = 0, replacedIdx = -1

    for(var i = 0; i < prevRecords.length; i++){
        if(prevRecords[i].uuid == userSettings.uuid){
            count++
            if(prevRecords[i].name == newRecord.name){
                replacedIdx = i
                break;
            }else if(count >= Consts.maxNumOfUserPerUUID ){// largest i ==> lowest score
                replacedIdx = i
            }
        }
    }

    return replacedIdx
}

/*init works like component.onComplete*/
var init = API.setTargetSrv("https://"+defVendor.firebaseUrl+"/")
