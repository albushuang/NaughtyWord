import QtQuick 2.4
import AppInit 0.1
import com.glovisdom.NWPleaseWait 0.1

Item { id: initDeck
    property var callback
    MouseArea{ id: mouseStealer
        anchors.fill:  parent
    }

    AppInit { id: initer
        onDeckReady: {
            callback(initDeck)
        }
    }

    function start(forced) {
        var overwrite = false
        if(typeof(forced)!="undefined") overwrite = forced
        initer.initDecks(overwrite)
    }
    Component.onCompleted: {
        NWPleaseWait.visible = true
        NWPleaseWait.color = "#9fcdcd"
        NWPleaseWait.state = "running"
        NWPleaseWait.externalFontSize = 20
        NWPleaseWait.message = qsTr("Checking decks...")
        NWPleaseWait.width = initDeck.width/1.5
        NWPleaseWait.height = initDeck.height/3

    }
    Component.onDestruction: {
        NWPleaseWait.setAsDefault(application)
    }
}


