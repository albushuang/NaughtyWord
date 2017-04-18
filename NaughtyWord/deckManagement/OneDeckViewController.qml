import QtQuick 2.0
import AppSettings 0.1
import "qrc:/generalModel"
import "qrc:/gvComponent"
import "qrc:/../../UIControls"
import "qrc:/NWUIControls"
import "qrc:/DictLookup"
import "qrc:/NWDialog"
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/objectCreate.js" as Create
import com.glovisdom.UserSettings 0.1


Item { id: controller
    property string deck
    state: "browse"
    states: [
        State {
            name: "browse"
            PropertyChanges{target: browseControl; visible: true }
            StateChangeScript {
                script: {
                    view.state = "deck"
                    if(typeof(own.iview)!="undefined"){
                        own.iview.enableBrowsing(false);
                        own.iview.delegator = own
                        own.setCard();
                    }
                }
            }
        },
        State {
            name: "lookup"
            PropertyChanges{target: browseControl; visible: false }
            StateChangeScript {
                script: {
                    view.state = "deckUpdate";
                    own.iview.enableBrowsing(true);
                    // dynamic create searchers here...
                }
            }
        }
    ]
    Component.onCompleted: {
        if (UserSettings.directLink) {
            own.moveBtn = Create.instantComponent(controller, "qrc:/MoveDeck/MoveDeckBtn.qml",
                                                  {creator: Create, deckPath: deckMedia.getDeckPath() })
            own.moveBtn.onRequestMove.connect(own.setSource);
            own.moveBtn.onMoveDone.connect(own.deckChanged);
            own.dummy = Create.instantComponent(controller, "qrc:/deckManagement/DummyFields.qml",
                                                  {creator: Create, deckPath: deckMedia.getDeckPath() })
        }
    }
    Component.onDestruction: {
        if(own.moveBtn!=null) { own.moveBtn.destroy() }
        if(own.dummy!=null) { own.dummy.destroy() }
    }

    AppSettings{id: appSettings}
    DictLookupView { id: view
        anchors.fill: parent
        state: "deck"
        delegator: own
        Component.onCompleted: {
            own.sview = getSynonymView();
            own.iview = getImageBrowser();
            own.iview.enableBrowsing(false);
            own.ready++;
        }        
        Text{id: pageText
            color: "white"; text: "(" + thisPage + "/" + own.totalCards + ")"
            width: 250*hRatio; height: 38*vRatio
            anchors{bottom: parent.bottom; bottomMargin: 25*vRatio;
                right: parent.right; rightMargin: 15*hRatio}
            font.pixelSize: height; fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignRight
            property int thisPage: own.totalCards > 0 ? own.cardIndex + 1 : 0
        }
        showDirectPic: UserSettings.directLink
    }
    Rectangle {
        width: 50; height: 50
        visible: UserSettings.directLink
        color: UserSettings.notesOnly ? "green": "grey"
        anchors { right: view.right; top: view.top }
        Text { text: "Notes\nOnly"; anchors.centerIn: parent }
        MouseArea { anchors.fill: parent
            onClicked: { UserSettings.notesOnly = !UserSettings.notesOnly }
        }
    }

    BrowseControl { id: browseControl
        delegator: own
        lImgUrl: "qrc:/pic/dictView_arrowLeft.png"
        rImgUrl: "qrc:/pic/dictView_arrowRight.png"
        dragTarget: controller
        dragExit: false
        property int px
        property int py
        property int dy
        onMpressed: { px = x; py = y }
        onYMoved: { view.moveDetail(py-y); dy = y-py; py=y }
        onMreleased: {
            if (Math.abs(dy)>15) { view.scrollDetail(dy*4) }
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_J || event.key == Qt.Key_Left) {
            own.clickedOnLeftBtn()
        } else if (event.key == Qt.Key_L || event.key == Qt.Key_Right) {
            own.clickedOnRightBtn()
        }
    }

//  browseControl steal mouse click in InputText. So cannot put these texts inside DictLookupView
    Text{id: goToSign; text: "To Word:"; color:"white"
        anchors{left: parent.left; leftMargin: 10*hRatio;bottom: goToPage.bottom; bottomMargin: 3}
        width: contentWidth; height: goToPage.height; font.pixelSize: height;
        verticalAlignment: Text.AlignTop
    }
    TextInput{id: goToPage; color: "white"; z:5
        text: "1"; selectByMouse: true
        anchors{bottom: parent.bottom; bottomMargin: 17*vRatio; left: goToSign.right; leftMargin: 5*vRatio }
        width: pageText.width/3;height: pageText.height
        font.pixelSize: height; font.underline: true
        horizontalAlignment: Text.AlignLeft;
        validator: IntValidator{bottom:1; top: own.totalCards}

        onAccepted: {
            own.goToPageNo(parseInt(text))
        }
    }
    DeckMedia { id: deckMedia
        deck: controller.deck
        soundON: UserSettings.soundAllON
        Component.onCompleted: {
            own.ready++;
        }
    }
    BrowseAllow { id: browseAllow
        dm: deckMedia
    }

    ListModel { id: synModel }
    ListModel { id: imgModel }
    NWDialogControl{id: dialog
        width: parent.width*2/3
    }

    ListModel { id: speechList }

    Sim2Tradition { id: langConverter
        function doNothing(cc) {return cc}
    }

    QtObject { id: own
        property ListModel speechListModel: speechList
        property var updater
        property var card
        property int ready:0
        property var sview
        property var iview
        property int cardIndex: 0
        property int totalCards
        property var langConvert: {
            var ret = langConverter.doNothing
            switch(appSettings.readSetting("NaughtyWord/Language")) {
            case "sc": ret = langConverter.simplify; break
            //case "tc": ret = langConverter.traditionalized; break
            case "tc": ret = langConverter.doNothing; break
            }
            return ret
        }
        property Item moveBtn
        property Item dummy
        function setSource() {
            moveBtn.setSource(deck, card.id)
        }

        function fillView(){
            if(typeof(card) != "undefined"){
                view.setWord(card.word);
                view.updateResult("");
                updateSynModel(card);
                sview.updateSynonym(synModel);
                setCard();
                setSpeech(card.id, card.speech!="");
                if(UserSettings.directLink) {
                    own.dummy.setWord(card.dummyWord)
                    own.dummy.setNote(card.dummyNote)
                    own.dummy.accuracy = card.imgAccuracy
                }
            }
        }
        function updateSynModel(card) {
            var cats = card.category.split("##");
            var syns = card.synonym.split("##");
            var sims = card.similar.split("##");
            var rels = card.related.split("##");
            var ants = card.antonym.split("##");
            synModel.clear()
            for (var i=0;i<cats.length;i++) {
                if(cats[i]!="") {
                    var element = new own.sview.synonymElement(cats[i], syns[i], sims[i], rels[i], ants[i]);
                    synModel.append(element);
                }
            }
        }
        function setCard() {
            imgModel.clear();
            var source = "file://" + deckMedia.getDeckPath() + deck + "/" + card.image
            //var element = new iview.imageElement(source, source,"");
            imgModel.append(iview.imageElement(source, source,""));
            iview.setModel(imgModel);
            view.updateResult(langConvert(Qt.atob(card.notes)));
        }

        function setSpeech(id, notEmpty) {
            speechList.clear();
            var url = [];
            if(notEmpty) {
                deckMedia.speechClicked(card.speech);
                url.push("");
            } else { return; }
            var elements = view.updateSpeechUrl(url);
            for (var i=0;i<elements.length;i++) {
                speechList.append(elements[i])
            }
        }
        function playSpeech() {
            deckMedia.speechClicked(card.speech);
        }
        function clickedOnUpBtn(y) { }
        function clickedOnDownBtn(y) { }

        function clickedOnLeftBtn() {
            var tryIndex = cardIndex
            if(--tryIndex<0) tryIndex = totalCards-1;
            checkCardAndBrowse(tryIndex)
        }
        function clickedOnRightBtn() {
            var tryIndex = cardIndex
            if(++tryIndex>=totalCards) tryIndex = 0;
            checkCardAndBrowse(tryIndex)
        }

        function checkCardAndBrowse(tryIndex) {
            if(browseAllow.browseCheck(tryIndex)){
                cardIndex = tryIndex
                card = deckMedia.browse(cardIndex)
            } else { lockMessage() }
        }

        function goToPageNo(no){
            var tryIndex = Math.max(0, Math.min(no - 1, totalCards))
            checkCardAndBrowse(tryIndex)
        }
        function lockMessage() {
            var message = Create.instantComponent(controller, "qrc:/gvComponent/FadingMessage.qml",
                            {width: width*0.8, height: height*0.2} )
            message.theText.text = qsTr("TOEIC battle stage locked.")
            message.life = 4000
            message.show()
        }

        // delegations
        function addCardClicked(iIndex, sIndex) {
            var word = card.word
            var note = card.note
            var accuracy = card.imgAccuracy
            if(dummy!=null) { word = dummy.getWord(); note = dummy.getNote(); accuracy=parseInt(dummy.accuracy) }
            updater.addCard(iIndex, sIndex, view.getFinalResult(), [word, note, accuracy])
        }

        function imageBrowserNeedAgent(url, index){ }
        function inputReturned(text) { }
        function textChanged(text) { }
        function userClearInput() { }
        function clickOnSpeech(index) {
            if(UserSettings.soundAllON) {
                if(state=="browse") { own.playSpeech(); }
                else  { updater.playAudio(index) }
            }
        }
        function viewUnload() {
            if(state=="lookup") {
                updater.destroy()
                updater = (function (){return})()
                state = "browse"
            }
            else {
                if(card!="undefined") {
                    deckMedia.releaseCard(card);
                }
                stackView.pop();
            }
        }
        function clickedOnSearchBtn() {
            if (controller.state == "lookup") return
            controller.state = "lookup";
            var prop = {
                cview: view,
                deckMedia: deckMedia,
                speechList: speechList
            }

            updater = Create.instantComponent(controller,
                                              "qrc:/deckManagement/OneDeckRelookup.qml", prop)
            updater.onTaskDone.connect(updateCard)
            updater.relookup(card)

        }
        function removeCardClicked() {
            dialog.show(qsTr("Are you sure to delete this card?"))
            dialog.callback = removeCardConfirmed
            dialog.hasInput = false
            dialog.cancelCB = removeCardCancel
        }
        function removeCardCancel(){ }
        function removeCardConfirmed(){
            var id = card.id
            deckMedia.removeCard(id);
            deckChanged()
        }
        function deckChanged() {
            deckMedia.releaseCard(card);
            totalCards = deckMedia.getRowCounts();
            if (cardIndex>=totalCards) cardIndex = 0;
            card = deckMedia.browse(cardIndex);
        }

        function updateCard() {
            updater.destroy();
            state = "browse"

            deckMedia.releaseCard(card);
            card = deckMedia.browse(cardIndex);
        }
        function otherKeyWordEnturned(inputs){
            if(inputs != ""){
                updater.otherKeyWordEnturned(inputs)
            }
        }
        function setDirectLink(text) {
            updater.setDirectLink(text)
        }
        onReadyChanged: {
            if(ready>1) {
                card = deckMedia.browse(cardIndex);
                totalCards = deckMedia.getRowCounts();
            }
        }
        onCardChanged: {
            own.fillView();
        }
    }
}

