import QtQuick 2.0

Item {
    property alias dsEnum: dictSourceEnum
    property var langConvert
    property Item langConverter
    QtObject{id: dictSourceEnum //dictSourceEnum
        readonly property int idNoDict: -1
        readonly property int idGDicts: 0
        readonly property int idWikiDict: 1
        readonly property int idAnkiGre7000: 2
        readonly property int idStartWithType: 3
        readonly property int idDummyNote: 4
        //    readonly property int idOtherDict1: 2
    }

    function getENote(notes) {
        return own.gDictBaseParser(notes, 1, "[EN] ", "")
    }

    function removeWord(note, word) {
        var indexLine = note.indexOf("\n")
        var indexWord = note.indexOf(word)
        if(indexWord < indexLine && indexWord >=0 ) {
            note = note.substr(indexLine+1)
        }
        return langConvert(note)
    }

    function parseNotes(notes, dictSource, maxTranslate, removeParentheses){
        if(dictSource == dictSourceEnum.idNoDict){
            dictSource = own.detectDictSource(notes)
        }
        var parsedNote
        switch(dictSource){
        case dictSourceEnum.idGDicts:
            parsedNote =  own.gDictsParser(notes, maxTranslate)
            break
        case dictSourceEnum.idAnkiGre7000:
            parsedNote = own.ankiGre7000Parser(notes, maxTranslate)
            break
        case dictSourceEnum.idStartWithType:
            parsedNote = own.skipFirstLineParser(notes, maxTranslate)
            break
        case dictSourceEnum.idDummyNote:
            parsedNote = own.dummyNotesParser(notes, maxTranslate)
            break
//TODO need to add other dictionary parser
        default:
            console.warn("Default parser is being used!!! Please try to all parsers for all dictionaries")
            parsedNote = own.defaultParser(notes, maxTranslate)
        }
        if(parsedNote.substr(-1,1) == "\n"){parsedNote = parsedNote.substr(0, parsedNote.length -1)}
        if(removeParentheses){ parsedNote = langConverter.handleParentheses(parsedNote) }
        //if(removeParentheses){ parsedNote = parsedNote.replace(/\(.*?\)/g, "").replace(/\（.*?\）/g, "")}//全型or半型 ()
        return langConvert(parsedNote)
    }

    QtObject{id: own
        function detectDictSource(notes){
//            console.log("notes:", notes)
            if(startWithType(notes)) {
                return dictSourceEnum.idStartWithType
            }

            if(notes.indexOf(langConvert("字義")) != -1 && notes.indexOf("[中]") != -1){
                return dictSourceEnum.idGDicts
            }
            if(notes.indexOf("<b") != -1){
                return dictSourceEnum.idAnkiGre7000
            }

            console.warn("Please add handler for new dictionary")
        }

        function startWithType(notes) {
            while(notes[0]=="\n" || notes[0]==" ") notes = notes.substr(1)
            var check = notes.substr(0, 10).toUpperCase()
            if (check.indexOf("- NOUN")!=-1 ||
                check.indexOf("- VERB")!=-1 ||
                check.indexOf("- ADJ")!=-1 ||
                check.indexOf("- ADV")!=-1) { return true }
            if (check.indexOf("- V.")!=-1  ||
                check.indexOf("- A.")!=-1  ||
                check.indexOf("- N.")!=-1 ||
                check.indexOf("- AD.")!=-1) { return true }
            if (check.indexOf("- PRE")!=-1 ||
                check.indexOf("- PRON")!=-1 ||
                check.indexOf("- PRED")!=-1 ||
                check.indexOf("- CON")!=-1) { return true }
            else { return false }
        }

        function gDictBaseParser(notes, maxTranslate, searchKey, titleItem) {
            var parsedNotes = ""
            var lineStart = 0, lineEnd = 0
            var count = 1
            var shift = searchKey.length
            while(count <= maxTranslate){
                lineStart = notes.indexOf(searchKey, lineEnd)  //Need +4 later
                if(lineStart != -1){
                    lineEnd = notes.indexOf("\n", lineStart)
                    if(lineEnd==-1) {
                        parsedNotes += titleItem + notes.slice(lineStart + shift)
                        break;
                    }
                    parsedNotes += titleItem + notes.slice(lineStart + shift, lineEnd+1)
                    count++
                }else{
                    return parsedNotes
                }
            }
            return parsedNotes
        }

        function gDictsParser(notes, maxTranslate){
            return gDictBaseParser(notes, maxTranslate, "[中] ", "•")
        }

        function ankiGre7000Parser(notes, maxTranslate){
            var startIdx = notes.indexOf("]") + 1
            var endIdx = notes.indexOf("<b")
            notes = notes.slice(startIdx, endIdx)
            return removeWeirdNone(notes)
        }

        function skipFirstLineParser(notes, maxTranslate){
            notes = notes.trim();
            while(notes[0]=="\n") {
                notes = notes.substr(1);
            }
            var nn = notes.substr(notes.indexOf("\n")+1)
            return nn.substr(0, nn.indexOf("\n"))
        }

        function dummyNotesParser(notes){
            return "•" + notes
        }

        function defaultParser(notes, maxTranslate){//Just get the frist maxTranslate lines
            var parsedNotes = ""
            var lineStart = 0, lineEnd = 0
            var count = 1
            while(count <= maxTranslate){
                lineEnd = notes.indexOf("\n", lineStart)
                if(lineEnd != -1){
                    if(lineStart == lineEnd){lineStart = lineEnd + 1; continue;} //Skip empty line
                    var nl = notes.slice(lineStart , lineEnd+1)
                    parsedNotes += updateNote(nl)
                    lineStart = lineEnd + 1
                }else{
                    if(lineStart < notes.length) {
                        var nl = notes.slice(lineStart )
                        parsedNotes += updateNote(nl)
                    }
                    return parsedNotes
                }
                count++
            }
            return parsedNotes
        }
        function updateNote(nl) {
            if (nl.slice(0, 6) == "source") { return "" }
            else return "•" + nl
        }
    }

    function removeWeirdNone(notes){ //There are a lot of weird "无" in the end
        var lastNone = notes.lastIndexOf("无")
        if(lastNone != -1 && notes.substr(lastNone+1).search(/[\u3400-\u9FBF]/) == -1){    //if "无" is last Chinese
            notes = notes.substr(0, lastNone) + notes.substr(lastNone+1)
        }
        return notes
    }

}

