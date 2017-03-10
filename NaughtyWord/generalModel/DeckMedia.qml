import QtQuick 2.4
import QtMultimedia 5.5
import com.glovisdom.AnkiDeck 0.1
import com.glovisdom.WordSpeaker 0.1
import GlobalBridgeOfImageProvider 0.1

Item { id: root
    property string deck
    property bool soundON: true
    property bool picOnly: false
    signal cardsReady(var cards)
    BridgeOfImageProvider { id: bridge }

    function setDeck(deckName) {
        AnkiDeck.deckInfo = deckName;
    }
    function getDeck() {
        return AnkiDeck.deckInfo
    }
    function getDeckPath() {
        return AnkiDeck.basePath
    }
    function getDeckID() {
        return AnkiDeck.getDeckID()
    }
    function getRootPath() {
        return "file://" + own.path
    }

    function addCard(card, imageGetter, speechGetter) {
        AnkiDeck.addCard(JSON.stringify(card), imageGetter.self(), speechGetter.self());
    }
    function addOrReplace(card, imageGetter, speechGetter) {
        AnkiDeck.addOrReplace(JSON.stringify(card), imageGetter.self(), speechGetter.self());
    }
    function makeUnique(deck) {
        var org = AnkiDeck.deckInfo
        AnkiDeck.deckInfo = deck
        AnkiDeck.makeUnique()
        AnkiDeck.deckInfo = org
    }

    function fetchCards(numberOfCard, filter, order, orderTarget, aheadDays, rangeStart, rangeEnd){
        var cardJsonString = AnkiDeck.getCards(numberOfCard, filter, order, orderTarget, aheadDays, rangeStart, rangeEnd)

        return own.getCardsByJsonString(cardJsonString)
    }

    function fetchCardsWithQueryStr(queryStr){
        cardJsonString = AnkiDeck.getCards(queryStr)
        return own.getCardsByJsonString(cardJsonString)
    }

    function fetchCardsAsync(numberOfCard, filter, order, orderTarget, aheadDays, queryStr){
        if(typeof(queryStr) != "undefined" && queryStr != ""){  //After AnkiDeck get cards. It will send a signal cardsReady
            AnkiDeck.getCardsAsync(queryStr)
        }else{
            AnkiDeck.getCardsAsync(numberOfCard, filter, order, orderTarget, aheadDays)
        }
    }

    function fetchCardsByIds(ids){
        var cardJsonString =  AnkiDeck.getCardsByIds(ids)
        var tempCards = own.getCardsByJsonString(cardJsonString)
        var returnCards = []
        for(var i = 0 ; i < ids.length; i++){
            for(var j = 0 ; j < tempCards.length; j++){
                if(tempCards[j].id == ids[i]){
                    returnCards[i] = tempCards[j]
                }
            }
        }
        return returnCards
    }

    function handleCardsReady(cardJsonString){
        cardsReady(own.getCardsByJsonString(cardJsonString))
    }

    function updateCard(card, updateItems) {
        // mystery: calling WordSpeaker.self() frequently causes WordSpeaker crashed.
        // AnkiDeck.updateCard(JSON.stringify(card), updateItems, bridge.self(), WordSpeaker.self());
        AnkiDeck.updateCard(JSON.stringify(card), updateItems, bridge.self(), WordSpeaker);
    }

    function updateCardAsync(card, updateItems) {
        AnkiDeck.updateCardAsync(JSON.stringify(card), updateItems, bridge.self(), WordSpeaker);
    }

    function updateCardImage(card, imager) {
        var newCard = {};
        own.copyImage(newCard, card)
        AnkiDeck.updateCard(JSON.stringify(newCard),
                            ["image", "imageURL", "orgX", "orgY", "Width", "Height"],
                            imager, imager);
    }

    function updateCardMedia(card, imager, speecher) {
        var newCard = {};
        own.copyMedia(newCard, card)
        AnkiDeck.updateCard(JSON.stringify(newCard),
                            own.prepareUpdateFields(newCard, card),
                            imager, speecher);
    }

    function updateCardNotes(card, imager, speecher) {
        var newCard = {};
        own.copyMedia(newCard, card)
        AnkiDeck.updateCard(JSON.stringify(newCard), ["notes", "dummyWord", "dummyNote", "imgAccuracy"],
                            imager, speecher);
    }

    function releaseCard(card){
        if(typeof(card)!="undefined") {
            AnkiDeck.releaseCard(card.id)
        }
    }

    function removeCard(id) {
        AnkiDeck.removeCard(id);
    }

    Audio { id: mediaAudio
        property bool commanded: false
        autoPlay: false
        onStatusChanged: {
            if(status==Audio.Loaded) {
                if (commanded == true) {
                    play();
                    commanded = false
                }
            }
        }
    }

    function speechClicked(resource) {
        if (soundON){
            if(!WordSpeaker.playFile(own.path + resource)) {
                resource = "file://" + own.path + resource
                mediaAudio.source = resource
                mediaAudio.commanded = true
                mediaAudio.play()
            }
        }
    }

    function browse(index) {
        var cardJsonString = AnkiDeck.browse(index)
        try {
        var card = JSON.parse(cardJsonString).cards[0];
        return card;
        } catch(err) {console.log(cardJsonString)}
    }
    function getRowCounts(filter, aheadDays){
        return AnkiDeck.getRowCounts(filter, aheadDays)
    }

    function pullInPractice() {
        var numberOfAheadDays = getNumberOfAheadDays()

        var allCards = fetchCards(-1, AnkiDeck.StatusReview, AnkiDeck.ASC, "due")
        var day = 1000 * 60 * 60 * 24
        for (var i = 0; i < allCards.length; i++){
            allCards[i].due -= numberOfAheadDays * day
            //update card one by one is inefficient. Should be improve in the future
            updateCardAsync(allCards[i], ["due"])
            releaseCard(allCards[i])
        }

    }

    function getNumberOfAheadDays(){
        var cards = fetchCards(1, AnkiDeck.StatusReview, AnkiDeck.ASC, "due")
        if(cards.length != 0){
            var mostDueCard = cards[0]
            var todayDeadLine = new Date()
            todayDeadLine.setDate(todayDeadLine.getDate()+1)
            todayDeadLine.setHours(4,0,0,0)

            var day = 1000 * 60 * 60 * 24
            var numberOfAheadDays = Math.ceil((mostDueCard.due - todayDeadLine.valueOf())/day)
            releaseCard(mostDueCard)
            return numberOfAheadDays
        }else{
            return 0
        }
    }

    function clearHistory(){
        AnkiDeck.clearHistory()
    }

    onDeckChanged: {
        own.path = AnkiDeck.basePath + deck + "/"
    }

    QtObject{id: own
        property string path //: "file://" + AnkiDeck.basePath + deck + "/"
        function getCardsByJsonString(cardJsonString){
            var cards = JSON.parse(cardJsonString).cards;

            if(typeof(cards) !== 'undefined'){
                return cards
            }else{
                return []
            }
        }
        function copyMedia(nc, c) {
            nc.id = c.id
            nc.word = c.word;
            nc.imageURL = c.imageURL+"";
            nc.orgX = c.orgX
            nc.orgY = c.orgY
            nc.Width = c.Width
            nc.Height = c.Height
            nc.notes = c.notes
            nc.dummyWord = c.dummyWord
            nc.dummyNote = c.dummyNote
            nc.imgAccuracy = c.imgAccuracy
            if (c.speechURL !== "") {
                nc.speechURL = c.speechURL+"";
            }
        }
        function prepareUpdateFields(nc, c) {
            var fields = ["image", "imageURL", "orgX", "orgY", "Width", "Height", "notes"]
            if (c.speechURL !== "") {
                fields.push("speech")
                fields.push("speechURL")
            }
            return fields
        }
    }

    Component.onCompleted: {
        AnkiDeck.deckInfo = deck;
        AnkiDeck.cardsReady.connect(root.handleCardsReady)
        own.path = AnkiDeck.basePath + deck + "/"
    }
    Component.onDestruction: {
        AnkiDeck.cardsReady.disconnect(root.handleCardsReady)
    }
}
