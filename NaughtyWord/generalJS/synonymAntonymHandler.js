.pragma library



function length(str, filterSameWord) {
    return toArray(str, filterSameWord).length
}

function toArray(str, filterSameWord, numOfArray, isRandom, prefix){
    var returnArr = []

    var arr1 = str.split("##")
    for(var i = 0; i < arr1.length; i++){
        var arr2 = arr1[i].split("|")
        for(var j = 0; j < arr2.length; j++){
            arr2[j] = arr2[j].trim()    //http://www.w3schools.com/jsref/jsref_trim_string.asp
            if(arr2[j] !== ""){
                var addThisWord = true
                if(filterSameWord){
                    for(var k = 0; k < returnArr.length; k++){
                        if(returnArr[k] == arr2[j]){
                            addThisWord = false
                            break;
                        }
                    }
                }
                if(addThisWord){
                    if(typeof(prefix) != "undefined"){
                        returnArr.push(prefix + arr2[j])
                    }else{
                        returnArr.push(arr2[j])
                    }
                }
            }
        }
    }

    if(typeof(numOfArray) != "undefined" && numOfArray != -1){
        numOfArray = Math.min(numOfArray, returnArr.length)
        if(isRandom){
            returnArr = getRandomArray(returnArr, numOfArray)
        }else{
            var tempArr = []
            for(i = 0; i < numOfArray; i++){
                tempArr.push(returnArr[i])
            }
            returnArr = tempArr
        }
    }

    return returnArr
}

function getRandomArray(oriArr, numOfArray){//Notice! this function change oriArr like called by reference
    var returnArr = []

    for(i = 0; i < numOfArray; i++){
        var randonIdx = Math.floor(Math.random()* oriArr.length)
        returnArr.push(oriArr[randonIdx])
        oriArr.splice(randonIdx,1)//Notice! this function change oriArr like called by reference
    }
    return returnArr
}

