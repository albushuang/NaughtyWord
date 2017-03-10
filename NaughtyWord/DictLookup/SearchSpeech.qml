import QtQuick 2.5
import SearchSpeech 0.1

Item { id: library
    property var callback
    property string sourceName: "sourceName"
    property string urlName: "url"
    property string fileName: "filename"

    ListModel { id: pronFound }

    QtObject{ id: own }

    SearchSpeech { id: seeker
        onSearchCompleted: {
            makeModel(seeker.urlList, true)
            callback(pronFound)
        }
    }

    function getModel() { return pronFound }
    function clearModel() { pronFound.clear() }
    function getSeeker() { return seeker }
    function search(key, cb) {
        if (typeof(cb)!="undefined") callback = cb
        seeker.searchKey = key
    }

    function makeModel(list, parse) {
        for (var i=0;i<list.length; i++) {
            var element, insert;
            if(parse) { element = parse2Element(list[i]); }
            else { element = list[i]; }

            if(element["sourceName"]=="shtooka" ||
               element["sourceName"]=="gdict") { pronFound.insert(0, element); }
            else { pronFound.append(element); }
        }
    }
    function parse2Element(item) {
        var result = item.split("@");
        var directories = result[1].split("/");
        var obj = {};
        obj[sourceName] = result[0]
        obj[urlName] = result[1]
        obj[fileName] = directories[directories.length-1]
        return obj
    }

}
