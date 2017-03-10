

function removeNotes(string) {
    var res = string.replace(/#/g, "");
    do {
        var indexB = res.indexOf("{{");
        if (indexB == -1) break;
        var indexE = res.indexOf("}}");
        if (indexB < indexE) {
            var note = res.slice(indexB+2, indexE);
            note = "{ " + note.replace(/\|/g, ",") + " }";
            res = res.slice(0, indexB) + note + res.slice(indexE+2)
        } else { // error handling...
            if(indexE == -1) {
                res = res.slice(0, indexB);
                break;
            }
            var error = res;
            do {
                indexB = res.indexOf("|");
                indexE = res.indexOf("}}");
                console.log(indexB, indexE);
                var indexS = error.slice(indexB, indexE-indexB+2).indexOf("|");
                if (indexS == -1) break;
                error = error.slice(indexB+1, indexE-indexB+2);
            } while (1);
            console.log(error);
            res = res.slice(0, res.indexOf(error)) + res.slice(indexE+2);
        }
    } while (true)
    return res;
}

function decodeHTMLEntities(text) {
    var entities = [ ['apos', '\''], ['amp', '&'], ['lt', '<'], ['gt', '>'],
                     ['quot', '"'], ['#x27', "'"], ['#x60', '`'] ];

    for (var i = 0, max = entities.length; i < max; ++i)
        text = text.replace(new RegExp('&'+entities[i][0]+';', 'g'), entities[i][1]);
    return text;
}

function getWikiExplanation(searchKey, callback) {
    var xhr = new XMLHttpRequest;
    var string = "http://www.igrec.ca/project-files/wikparser/wikparser.php?query=def&count=20&lang=en&word=" + searchKey;
    var notFound = false;
    xhr.open("GET", string.toLowerCase());
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            var wholeText = "";
            var decoded = decodeHTMLEntities(xhr.responseText);
            decoded = removeNotes(decoded);
            var stringList = decoded.split("|");
            for (var i=0;i<stringList.length;i++) {
                var means = stringList[i].trim();
                if (means != "") {
                    if (means.substr(0,6)!="ERROR:") {
                        wholeText = wholeText + "[EN] " + means + "\n";
                    } else {
                        wholeText += "##" + qsTr("Not found.\n");
                        notFound = true;
                    }
                }
            }
            callback(wholeText);
        }
        delete xhr;
    }
    xhr.send();
}



