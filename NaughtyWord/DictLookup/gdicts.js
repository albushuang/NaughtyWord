.pragma library

var phoneticID = "phonetic";
var noteID = "note";
var messageID = "message";
var meaningCount;
var sim2Tra


function checkEscape(revertString) {
    while(true) {
        var exist = revertString.search("~~x");
        if (exist>=0) {
            var numberStr = revertString.substr(exist, 5);
            var number = parseInt(numberStr.replace(/~~/g, "0"));
            revertString = revertString.replace(numberStr, String.fromCharCode(number));
        }
        else break;
    }
    return revertString;
}

function parseTerms(terms, networkResult) {
    var phonetic = "";
    for (var i=0;i<terms.length;i++) {
        var revertString = terms[i].text;
        revertString = checkEscape(revertString);
        if (terms[i].type=="phonetic") {
            var label = terms[i].labels[0].text
            if(phonetic.indexOf(label) == -1){
                phonetic += label + ": " + revertString + ";   ";
            }
        }
        else if(terms[i].type=="sound") {
            appendToSpeech(terms[i].text)
        }
    }
    networkResult.push({type:phoneticID, text: phonetic });
}

var pronFound = []; // this might have naming polution

function appendToSpeech(url) {
    var filenames = url.split("/");
    pronFound.push({"sourceName": "gdict",
                      "url"       : url,
                      "filename"  : filenames[filenames.length-1]});
}

function getNotes(terms) {
    var wholeText = "";
    if (terms.type=="text") {
        var revertString = terms.text;
        revertString = checkEscape(revertString);
        if (terms.language=="en") {
            wholeText += "[EN] " + revertString + "\n";
        } else {
            var note = sim2Tra(revertString);
            wholeText += "[中] " + note + "\n";
        }
    }
    return wholeText
}

function rearrange(subSum) {
//    console.log("subSum", subSum)
    var meanings = subSum.split("\n");
    var returnString = "";

    /*Gdict might sometimes break the translation improperly. For exmaple,
    [中] 警方
    [中] 逮捕；拘押   ==> the Correct one should be [中] (警方)逮捕；拘押*/
//    console.log("meanings.length", meanings.length)
    var redudentBreak = meanings.length > 3

    if(meanings.length > 5){
        console.warn("We do not know Gdict might provide translation more than 4." +
                 " Please make sure that we can handle this case properly. subSum:", subSum)
    }

    for(var i=0;i<meanings.length;i++) {
        var ch = "[中] ", realMeaningStart = ch.length
        if (meanings[i].indexOf(ch)==0){
            if(redudentBreak){
                if(returnString.indexOf(ch) != -1){
                    returnString += meanings[i].substring(realMeaningStart) + "\n";
                }
                else{
                    returnString += ch + "(" + meanings[i].substring(realMeaningStart) + ")";
                }
            }else{
                returnString += meanings[i] + "\n";
            }
        }
    }
    for(var i=0;i<meanings.length;i++) {
        var en = "[EN] ", realMeaningStart = en.length
        if (meanings[i].indexOf(en)==0){
            if(redudentBreak ){
                if(returnString.indexOf(en) != -1){
                    returnString += meanings[i].substring(realMeaningStart) + "\n";
                }
                else{
                    returnString += en + "(" + meanings[i].substring(realMeaningStart) + ")";
                }
            }else{
                returnString += meanings[i] + "\n";
            }
        }
    }
    return returnString;
}

function getMeaning(entries, networkResult, partOfSpeech) {
    var wholeText = sim2Tra("字义") + meaningCount.toString() + ": " + partOfSpeech + "\n";
    var terms = entries.terms;
    var subSum = "";
    for (var j=0;j<terms.length;j++) {
        subSum += getNotes(terms[j]);
    }
    wholeText += rearrange(subSum);
    meaningCount++;
    networkResult.push({type:noteID, text: wholeText});
}

/*詞性可能會出現在：
1. 第一層entries的labels
2. 第二層enteries下面terms的labels (只會其中一個term有詞性)*/
function getPartOfSpeech(entries){//partOfSpeech = 詞性
    if(typeof(entries.labels) != "undefined"){
        for(var j = 0; j < entries.labels.length; j ++){
            if(entries.labels[j].title == "Part-of-Speech"){ return entries.labels[j].text}
        }
    }
    var terms = entries.terms
    for (var i = 0; i< terms.length; i++) {
        if(typeof(terms[i].labels) != "undefined"){
            for(j = 0; j < terms[i].labels.length; j ++){
                if(terms[i].labels[j].title == "Part-of-Speech"){ return terms[i].labels[j].text}
            }
        }
    }
    return ""
}

function parseEntries(entries, networkResult) {
    var partOfSpeech = getPartOfSpeech(entries) //partOfSpeech = 詞性
    partOfSpeech = partOfSpeech != "" ? "(" + convertPartOfSpeechToShort(partOfSpeech) + ")" : ""
    if(entries.type=="meaning") {
//        console.log("entry 1. part of speech", partOfSpeech)
        getMeaning(entries, networkResult, partOfSpeech);
    }
    var theEntries = typeof(entries.entries) != "undefined" ? entries.entries: [];

    for (var i=0;i<theEntries.length;i++) {
        if (theEntries[i].type=="meaning") {
//            console.log("entry 2. part of speech", partOfSpeech)
            getMeaning(theEntries[i], networkResult, partOfSpeech);
        }
    }
}

function parsePrimaries(primaries, networkResult) {
    meaningCount = 1;
    for (var j=0;j<primaries.length;j++) {
        parseTerms(primaries[j].terms, networkResult);
        for (var i=0;i<primaries[j].entries.length;i++) {
            parseEntries(primaries[j].entries[i], networkResult);
        }
    }
}

// english-chinese :http://api.pearson.com/v2/dictionaries/ldec/entries?headword=book
// search pronounciation: http://api.pearson.com/v2/dictionaries/ldoce5/entries?headword=book&audio=pronunciation


function getLongManResult(theKey, results, networkResult) {
    for (var i=0;i<results.length;i++) {
        if (results[i].headword == theKey) {
            for (var j=0;j<results[i].senses.length; j++) {
                results[i].senses[j].translation = "[中] " + results[i].senses[j].translation + "\n"
                networkResult.push(results[i].senses[j])
            }
        }
    }
}

function lookupGDict(searchKey, callback) {
    var xhr = new XMLHttpRequest;
    var theKey = searchKey.trim() //.replace(/ /g, "%20");
    var string = "http://api.pearson.com/v2/dictionaries/ldec/entries?headword=" + theKey;
    var networkResult = [];
    pronFound = [];

    var notFound=false;
    xhr.TimeOut = 3000
    xhr.open("GET", string.toLowerCase());
    xhr.onreadystatechange = function() {
        var ret = qsTr("source：Pearson\n")
        if (xhr.readyState == XMLHttpRequest.DONE) {
            try {
                var qStatus = JSON.parse(xhr.responseText);
                if (qStatus != "undefined") {
                    getLongManResult(theKey, qStatus.results, networkResult);
                }
                if(networkResult.length == 0) { notFound=true; }
            }
            catch (err) {
                console.log("parse error:"+err)
                ret = qsTr("Network error! The dictionary requires internet access.")
                if(xhr.responseText=="") { notFound = false }
                else { notFound=true; }
            }
            if(notFound) {
                networkResult.push ({ type: messageID, text: qsTr("no definition found.\n\n")})
            }
            callback(ret, networkResult, pronFound, notFound);
        }
        delete xhr;
    }
    xhr.send();
}

function checkLanguage(word) {
    var ucWord = word.toUpperCase().trim();
    var firstChar = ucWord.charAt(0);
    if (firstChar>='A' && firstChar <='Z') return "en"
    else return "UI";
}

function convertPartOfSpeechToShort(partOfSpeech){
    switch(partOfSpeech){
    case "noun":
        return "n."
    case "verb":
        return "v."
    case "adjective":
        return "adj."
    case "adverb":
        return "adv."
    case "conjunction":
        return "conj."
    case "pronoun":
        return "pron."
    case "preposition":
        return "prep."
    case "interjection":
        return "int."
    case "exclamation":
        return "int."
    default:
        return partOfSpeech
    }
}
