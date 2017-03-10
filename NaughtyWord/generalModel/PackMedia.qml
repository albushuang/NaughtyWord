import QtQuick 2.4
import QtMultimedia 5.5
import AnkiPackage 0.1
import com.glovisdom.AnkiDeck 0.1
import AudioWorkaround 0.1
import AnkiTranslator 0.1

Item {
    property string deck
    property var models
    property bool soundON: true
    property bool picOnly: false
    signal cardsReady(var cards)

    AnkiPackage { id: anki }
    AnkiTranslator { id: translator }
    AudioWorkaround { id: workAround }

    function setDeck(deckName) {
        anki.openPackage(deck)
        models = anki.models
    }
    function getDeck() {
        var names = anki.basePath.split("/")
        return names[names.length-2]
    }
    function getDeckID() {
        return anki.getDeckID()
    }
    function fetchCards(numberOfCard, filter, order, orderTarget, aheadDays){
        var cardJsonString

        if(picOnly) {
            cardJsonString = anki.getPicCards(numberOfCard,
                                           translator.toAnkiFilter(filter),
                                           translator.toAnkiOrder(order),
                                           translator.toAnkiField(orderTarget),
                                           aheadDays)
        } else {
            cardJsonString = anki.getCards(numberOfCard,
                                           translator.toAnkiFilter(filter),
                                           translator.toAnkiOrder(order),
                                           translator.toAnkiField(orderTarget),
                                           aheadDays)
        }
        var res = translator.toKMRJJSON(cardJsonString, anki.models, true)
        var cards = own.getCardsByJsonString(res)
        own.prepareMedia(cards);
        return cards
    }

    function fetchCardsAsync(numberOfCard, filter, order, orderTarget, aheadDays){
        fetchCards(numberOfCard, filter, order, orderTarget, aheadDays)
    }

    function updateCard(card, updateItems) {
        var cardString = JSON.stringify(card)
        var newCard = translator.toAnkiJSON(cardString)
        anki.updateCard(newCard, updateItems);
    }

    function updateCardAsync(card, updateItems) {
        updateCard(card, updateItems);
    }

    function releaseCard(card){
        if(typeof(card)!="undefined") {
            workAround.releaseResource(card.id)
        }
    }
    function getRootPath(){
        return "file://" + anki.basePath
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
            resource = resource
            mediaAudio.source = resource
            mediaAudio.commanded = true
        }
    }
    function getRowCounts(filter, aheadDays){
        return anki.getRowCounts(translator.toAnkiFilter(filter), aheadDays)
    }

    function pullInPractice() {
        var numberOfAheadDays = getNumberOfAheadDays()
        var day = 1000 * 60 * 60 * 24
        anki.pullInPractice(numberOfAheadDays * day)
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
            console.log("AheadDays", numberOfAheadDays)
            return numberOfAheadDays
        }else{
            return 0
        }
    }

    function clearHistory(){
        anki.clearHistory()
    }

    QtObject{id: own
        function getCardsByJsonString(cardJsonString){
            var cards
            try {
                cards = JSON.parse(cardJsonString).cards;
            } catch (err) {
                console.log("error!", err, cardJsonString)
            }

            if(typeof(cards) !== 'undefined'){
                return cards
            }else{
                return []
            }
        }
        function prepareMedia(cards) {
            for (var i=0;i<cards.length;i++) {
                cards[i].word = Qt.atob(cards[i].word);
                if (cards[i].image!="") {cards[i].image = prepareImage(cards[i].image) }
                if (cards[i].speech!="") {cards[i].speech = prepareSpeech(cards[i]) }
            }
        }
        function prepareImage(source) {
            var names = source.split("##")
            return names[1]
        }

        function prepareSpeech(card) {
            return "file://"+workAround.makeResourceReady(card.id, card.speech, deck)[0]
        }
    }

    Component.onCompleted: {
        setDeck(deck)
        //anki.cardsReady.connect(handleCardsReady)
    }
}
