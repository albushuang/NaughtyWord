import QtQuick 2.0

Item {
    id: root
    property var blocks: []
    property int blockNumber: 3
    property int lifeTime: 2000
    property int interval: 500

    function start() {
        intervalControl.running = true
    }
    function reset() {
        intervalControl.number = 0
    }

    Timer { id: intervalControl
        property int number: 0
        interval: root.interval
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            anim.itemAt(number).running = true
            number++
            if(number>=blocks.length) {
                repeat = false
                running = false
            }
        }
    }

    Repeater { id: anim
        model: blockNumber
        Item {
            property alias running: animator.running
            NumberAnimation { id: animator
                target: blocks[index]
                property: "x"
                duration: lifeTime
                to: blocks[index].destination
            }
        }
    }
}
