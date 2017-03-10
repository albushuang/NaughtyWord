.pragma library

/*To get a sub array or oriArr.
num: the length of subArray you want to get, if num > oriArr.length. you will get whole oriArr
toRemove: if toRemove = true, oriArr will be lose those items. Default value = true */
function getRandomItems(oriArr, num, toRemove) {
    if(typeof(toRemove) == "undefined"){toRemove = true}
    if(typeof(oriArr.length) == "undefined"){console.assert(false, "Please make sure you pass an array to oriArr")}
    var tempArr, rtnArr = []
    if(toRemove){ tempArr = oriArr} //Any modification of tempArr influence oriArr
    else{ tempArr = oriArr.slice()} //copy by clone

    var arrLength = tempArr.length
    for(var i = 0; i < num && i < arrLength; i++){
        var randIdx = Math.floor(Math.random() * tempArr.length)
        rtnArr.push(tempArr.splice(randIdx,1)[0])
    }

    return rtnArr
}

