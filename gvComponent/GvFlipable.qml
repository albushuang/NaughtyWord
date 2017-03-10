import QtQuick 2.0

Flipable { id: flipable
    property bool flipped: false
    property int flipDuration: 4000
    property int rotationAngle: 180
    property real rotationOriginX: width/2
    property real rotationOriginY: height/2
    transform: Rotation {
        id: rotation
        origin.x: rotationOriginX
        origin.y: rotationOriginY
        axis.x: 0; axis.y: 1; axis.z: 0
        angle: 0
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: rotationAngle }
        when: flipable.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: flipDuration }
    }

    function flip() {
        flipable.flipped = !flipable.flipped
    }
}
