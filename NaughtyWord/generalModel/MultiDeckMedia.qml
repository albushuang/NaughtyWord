import QtQuick 2.4
import QtMultimedia 5.5
import com.glovisdom.AnkiDeck 0.1
import com.glovisdom.WordSpeaker 0.1
import GlobalBridgeOfImageProvider 0.1
import "qrc:/gvComponent"

DeckMedia { id: root
    property var decks: []
    property var deck: "fruits.lif.kmrj"
    function fetchCards(numberOfCard, filter, order, orderTarget, aheadDays, queryStr){
        var cards = []
        for (var i=0;i<numberOfCard;i++) {
            var r = Math.floor(Math.random()*decks.length)
            AnkiDeck.deckInfo = decks[r]
            var cardJsonString = AnkiDeck.getCards(1, filter, order, orderTarget, aheadDays)
            var one = own.getCardsByJsonString(cardJsonString)[0];
            one.image = decks[r]+"/"+one.image;
            one.speech = decks[r]+"/"+one.speech;
            cards.push(one)
        }

        return cards
    }

    function fetchCardsAsync(numberOfCard, filter, order, orderTarget, aheadDays, queryStr){
        //return fetchCards(numberOfCard, filter, order, orderTarget, aheadDays, queryStr);
        own.cardsWanted = numberOfCard
        own.cardsGot = 0
        own.cardsGathered = []
        own.filter = filter
        own.order = order
        own.orderTarget = orderTarget
        own.aheadDays = aheadDays
        own.fetchOneAsyn()
    }

    function getRootPath() {
        return "file://" + AnkiDeck.basePath
    }

    function handleCardsReady(cardJsonString){
        var one = getCardsByJsonString(cardJsonString)[0];
        one.image = AnkiDeck.deckInfo+"/"+one.image;
        one.speech = AnkiDeck.deckInfo+"/"+one.speech;
        own.cardsGathered.push(one)
        own.cardsGot++
        own.fetchOneAsyn()
    }

    QtObject{id: own
        property int cardsWanted
        property int cardsGot
        property var cardsGathered: []
        property var filter
        property var order
        property var orderTarget
        property var aheadDays
        function getCardsByJsonString(cardJsonString){
            var cards = JSON.parse(cardJsonString).cards;
            if(typeof(cards) !== 'undefined'){
                return cards
            }else{
                return []
            }
        }
        function fetchOneAsyn() {
            if(cardsGot<cardsWanted) {
                var r = Math.floor(Math.random()*decks.length)
                AnkiDeck.deckInfo = decks[r]
                AnkiDeck.getCardsAsync(1, filter, order, orderTarget, aheadDays)
            } else {
                cardsReady(own.cardsGathered)
            }
        }

    }

    Component.onCompleted: {
        //AnkiDeck.cardsReady.connect(own.handleCardsReady)
    }
    Component.onDestruction: {
        //AnkiDeck.cardsReady.disconnect(own.handleCardsReady)
    }
}
