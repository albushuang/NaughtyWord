import QtQuick 2.0
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import QtMultimedia 5.0
import "../generalModel"
import "qrc:/../../UIControls"
import "../NWUIControls"
import "../generalJS/objectCreate.js" as Create
import "../generalJS/appsettingKeys.js" as AppKeys
import "qrc:/gvComponent"

// report: error in downloading?
// TODO: copy meaning...
// TODO: try lookup in cell phone
// TODO: when a word is not found, clear previous found...
// TODO: service term of bing, etc...
// TODO: after lookup word, rollback meaning text....and etc.
// TODO: destroy tutorial when page is finished.
// TODO: add WordNet?
Item { id: lookupController
    property alias speechListModel: speechList
    property bool moreWord: false;
    property real initEF: 2.5
    property int pronSelect: 0;
    property Item tutor
    property alias deckMedia: theDeckMedia
    property alias view: view
    signal wordSaved()

    AppSettings { id: appSettings }  //We can get app default file path from C++
    DeckMedia { id: theDeckMedia
        soundON: UserSettings.soundAllON
        deck: UserSettings.addDeck;
    }
    ListModel { id: suggestionList }
    ListModel { id: speechList }

    DictLookupModel { id: dictionary
        language: appSettings.readSetting("NaughtyWord/Language")
    }
    DragMouseAndHint {
        target: lookupController
        maxX: lookupController.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
    }
    DictLookupView { id: view
        suggestionModel: suggestionList
        anchors.fill: parent
        delegator: lookupController
        showDirectPic: UserSettings.directLink
        Component.onDestruction: allInputMethodFocusFalse()
    }
    function allInputMethodFocusFalse(){
        if(view.showDirectPic) { view.directPicture.inputText.focus = false }
        view.userInput.inputText.focus = false
        view.otherKey.inputText.focus = false
    }

    function setDirectLink(text) {
        imageBrowserController.setDirectLink(text)
    }
    function clickedOnSearchBtn() {}

    SynonymController { id: synonymController }
    ImageBrowserController { id: imageBrowserController }

    Component.onCompleted: {
        dictionary.onLookedUp.connect(lookupResult);
        dictionary.onFoundMeaning.connect(own.detailsFound);

        dictionary.onFoundPron.connect(updatePron);
        synonymController.setView(view.getSynonymView());
        imageBrowserController.setView(view.getImageBrowser());
        prepareTutorial();
    }

    function saveCompeletedReminder(object){
        if(UserSettings.wordSavedRemind){
            var prop = {
                reminderType: UserSettings.remindTypeWordSaved,
                remindCancelOption: true,
                reminderDuration: 3700
            }
            var text = qsTr("Card is saved in deck \"%1\".").arg(theDeckMedia.deck.split(".")[0])
            var reminder = Create.instantComponent(lookupController, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
            reminder.showReminder(text, reminder.enumDirection.left)
            reminder.noRemindClicked.connect(noRemindClicked)
            reminder.cycleEndCallback = reminder.destroy;
        }
        deleteLater.object = object
        deleteLater.start()
    }

    Timer { id: deleteLater
        property var object
        triggeredOnStart: false
        interval: 1
        repeat: false
        onTriggered: { object.destroy(); wordSaved() }
    }

    function noRemindClicked(type){
        if (type == UserSettings.remindTypeWordSaved)
            UserSettings.wordSavedRemind = false
    }


    // PRAGMA: MV"C" function ==========================================================
    function synonymSearchCallback() {
        imageBrowserController.setSynonym(synonymController.get3Synonyms());
    }

    // PRAGMA: delegations of M"V"C  ===================================================
    function updateIndexUp(index) { return Math.max(0, index-1); }
    function updateIndexDown (index) {
        checkMoreResult(index);
        return Math.min(suggestionList.count-1, index+1);
    }
    function checkMoreResult(index) {
        if (index > suggestionList.count-3) {
            moreWord = true;
            var key = suggestionList.get(index).word.split("=");
            dictionary.moreResult(key[0]);
        }
    }
    function clickOnSuggestItem(index) {
        inputReturned("", index);
        view.userInput.focusOff();
    }

    function inputReturned(inputs, index) {
        view.state = "result";
        try {
            inputs = suggestionList.get(index).word;
        }
        catch (err){
            inputs = view.getWord();
        }

        lookup(inputs)
    }
    function lookup(inputs) {
        UserSettings.searchCount++
        speechList.clear()
        own.clearContent()
        inputs = dictionary.checkResult(inputs, extractContentAndUpdateView);
        view.updateTextInput(inputs);

        suggestionList.clear();
        imageBrowserController.search(inputs, true, false);
        dictionary.searchPron(inputs);
        synonymController.searchSynonym(inputs, synonymSearchCallback);
    }

    function extractContentAndUpdateView(input) {
        var contents = input.split("=");
        own.cardResult = [];
        own.cardResult.push("");
        own.cardResult.push(contents[1]);
        view.updateResult(contents[1]);
        return contents[0];
    }

    function otherKeyWordEnturned(inputs){
        if(inputs != ""){
            UserSettings.useOtherKeyCount++
            imageBrowserController.search(inputs, false, true);
            checkTutor("tutUseAnotherKeyWord1")
        }
    }

    function textChanged(text) { dictionary.setSearchKey(text); }
    function suggestContent(index) {
        if (index>=0) { return suggestionList.get(index).word; }
        else { return ""; }
    }
    function userClearInput() { suggestionList.clear(); }
    function viewUnload() { stackView.pop(); }

    function addCardClicked(imageIndex, speechInd) {
        checkTutor("tutSaveWord")
        UserSettings.addCardCount++

        own.cardResult[1] = view.getFinalResult();
        var speechUrl
        if(speechList.count>0 &&
           speechInd >= 0 && speechInd<speechList.count) {
            speechUrl = speechList.get(speechInd).url
        } else { speechUrl = "" }

        var info = view.getImageBrowser().reportCropInfo();
        var obj = Create.instantComponent(lookupController, "qrc:/DictLookup/SaveAWordController.qml",
                                { width: parent.width/1.5, height: parent.height/3,
                                  deckMedia: theDeckMedia,
                                  imageGetter: imageBrowserController.imageBrowserGetImageGetter(),
                                  makeWordCallback:  callbackForSaveAWord,
                                  cropInfo: info,
                                  dataFromServer: imageBrowserController.getDataFromServer()});
        obj.saveCompeleted.connect(saveCompeletedReminder)
        obj.setUserDeck(theDeckMedia.deck);
        obj.setImageURL(imageBrowserController.imageBrowserGetURL(imageIndex),
                        imageBrowserController.imageBrowserGetTB(imageIndex));
        obj.setSpeechURL(speechUrl);
    }

    function callbackForSaveAWord(imgUrl, PrnUrl) {
        var word = getDetailJSON();
        word["speechURL"] = PrnUrl;
        word["imageURL"] = imgUrl;
        return word;
    }

    function getDetailJSON() {
        var paString = own.cardResult[0];
        var notesString = own.cardResult[1];
        var oneRecord = {
            "word": view.getWord(),
            "pa": paString,
            "notes": notesString,
            "ef": initEF, "status": 0,  "learningStep": 0,
            "interval": 0, "due": 0, "lastStudy": 0, "lapseCount":0, "ansHistory": 1 };
        synonymController.composeSynonym(oneRecord);
        return oneRecord;
    }
    function dictBtnClicked() {
        stackView.vtSwitchControl(
                            "qrc:/DictionaryManager/DictionaryViewController.qml",
                            {}, false, false, true);
    }
    Audio { id: wordPron }
    function clickOnSpeech(ind) {
        if(UserSettings.soundAllON) {
            wordPron.source = speechList.get(ind).url
            wordPron.play();
        }
    }

    // PRAGMA: "M"VC functions ===========================================================
    function lookupResult(words) {
        if (moreWord) { moreWord = false; }
        else { suggestionList.clear();}
        for (var i=0;i<words.length;i++) {
            suggestionList.append({word:words[i]});
        }
    }

    QtObject { id: own
        property var cardResult;
        function clearContent() {
            view.updateResult("")
            cardResult = []
        }

        function detailsFound(source, textArray) {
            prepareCard(source, textArray)
            //var mainTxt = formatDetails(textArray)
            view.updateResult(cardResult[1]);
        }

        function formatDetails(mArray) {
            var whole = "";
            for(var i=0;i<mArray.length;i++) {
                if(mArray[i].type==dictionary.phoneticID ||
                   mArray[i].type==dictionary.noteID) {
                    var toAdd = mArray[i].text
                    if (toAdd.slice(0,2)=="##") {
                        toAdd = toAdd.slice(2);
                    }
                    whole += toAdd + "\n";
                }
            }
            return whole;
        }
        function prepareCard(source, mArray) {
            cardResult = [];
            var notes = "";
            var phonetic = "";
            for(var i=0;i<mArray.length;i++) {
                //notes += "[中] " + mArray[i].translation + "\n";
                notes += mArray[i].translation;
            }
            cardResult[0] = phonetic;
            cardResult[1] = notes + "\n" + source;
        }
        function prepareCardGDict(source, mArray) {
            cardResult = [];
            var notes = "";
            var phonetic = "";
            for(var i=0;i<mArray.length;i++) {
                if(mArray[i].type==dictionary.phoneticID) {
                    phonetic += mArray[i].text + "\n";
                }
                if(mArray[i].type==dictionary.phoneticID ||
                   mArray[i].type==dictionary.noteID) {
                    if (mArray[i].text.slice(0,2)!="##") {
                        notes += mArray[i].text + "\n";
                    }
                }
            }
            cardResult[0] = phonetic;
            cardResult[1] = notes + "\n" + source;
        }
    }

    function updatePron(model) {
        var urlList = [];
        for (var i=0;i<model.count;i++) {
            urlList.push(model.get(i).url);
        }
        var elements = view.updateSpeechUrl(urlList);
        speechList.clear();
        for (i=0;i<elements.length;i++) {
            speechList.append(elements[i])
        }
    }


    // tutorials ====================================================================
    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property variant tutArrayInThisQML: [UserSettings.tutUseAnotherKeyWord1, UserSettings.tutUseDictionary,
    UserSettings.tutSaveWord]

    function prepareTutorial() {
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                tutor = Create.instantComponent(lookupController, "qrc:/DictLookup/DictLookupTutor.qml", {});
                Create.createComponent(lookupController, tutorialQmlUrl,
                                        {width: lookupController.width, height: lookupController.height},
                                       tutor.startHanldeTutorial)
                break
            }
        }
    }
    function checkTutor(script) {
        if(tutor!=null)
            tutor.isOnGoing(script)
    }
    Component.onDestruction: {
        if(tutor != null) tutor.destroy()
    }
}

