import QtQuick 2.0
import CardMover 0.1

Rectangle { id: moveBtn
    property var creator
    property string deckPath
    signal requestMove()
    signal moveDone()

    width: 50; height: 50
    color: "orange"
    anchors { left: view.left; top: view.top }
    Text { text: "Move to"; anchors.centerIn: parent }
    MouseArea { anchors.fill: parent
        onClicked: {
            requestMove()
            if(typeof(moveBtn.selectTarget)=="undefined") {
                own.selectTarget = creator.instantComponent(moveBtn, "qrc:/MoveDeck/TargetController.qml",
                                                            {callBack: own.moveDeck,
                                                            mover: mover})
            } else {
                own.selectTarget.visible = true
            }
        }
    }

    CardMover { id: mover
        basePath:deckPath
    }

    Component.onDestruction: {
        if(typeof(moveBtn.selectTarget)!="undefined") {
            own.selectTarget.destroy()
        }
    }

    QtObject { id: own
        property var selectTarget
        property var source
        property var cardID

        function moveDeck(target) {
            mover.moveCard(source, target, cardID)
            moveDone()
        }
    }

    function setSource(source, id) {
        own.source = source
        own.cardID = id
    }

}
