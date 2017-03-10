import QtQuick 2.5
import "qrc:/../../UIControls"

AutoImage {
    property var sources
    property var clickeds
    state: "main"
    states: [
        State { name: "main"
            StateChangeScript { script: {
                source = sources[0]
                own.clicked = clickeds[0]
            } }
        },
        State { name: "sub"
            StateChangeScript { script: {
                source = sources[1]
                own.clicked = clickeds[1]
            } }
        }
    ]
    QtObject { id: own
        property var clicked
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            own.clicked();
        }
    }
}
