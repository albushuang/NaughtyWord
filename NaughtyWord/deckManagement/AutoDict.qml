import QtQuick 2.0
import QtQuick.Controls 1.4
import com.glovisdom.AnkiDeck 0.1
import "../generalJS/objectCreate.js" as Create
import "qrc:/DictLookup"

Item { id: autoDict;
    property var lookup
    property var words: []
    property int count: 0
    property string deck

    ListModel{ id: empty }

    function start() {
        words = AnkiDeck.getAllWords()
        checkOne();
    }
    function checkOne() {
        if (count>words.length) {
            console.log("lookup completed!!!!!!!!!!!!")
            return
        }
        console.log("looking up...", words[count])
        lookup.updatePron(empty)
        lookup.textChanged(words[count])
        lookup.inputReturned("", 0)
        //lookup.lookup(words[count])
        count++
        dTimer.start()
    }

    Timer { id: dTimer
        triggeredOnStart: false
        repeat: false
        interval: 3000
        onTriggered: {
            console.log("start saving...")
            lookup.addCardClicked(0,0)
        }
    }

    DictLookupController { id: lookup
        anchors.fill: parent
        onWordSaved: { checkOne() }
        view.state: "result"
    }
    Component.onCompleted: {
        console.log(lookup, lookup.deckMedia, lookup.deckMedia.deck)
        lookup.deckMedia.deck = deck
        lookup.deckMedia.setDeck(deck)
        console.log(lookup.deckMedia.getRootPath())
    }
}
