import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4

Item { id: wait
    property alias message: theText.text
    property bool hasButton: false
    property var buttonClicked
    property var callbackData
    property string buttonText
    property var callbackAfterForceRedraw
    property int externalFontSize
    property alias iwidth: busyIndicator.width
    property alias iheight: busyIndicator.height
    property alias color: background.color
    anchors.centerIn: parent

    function setStyle (comp) {
        busyIndicator.style = comp
    }

    states: [
        State {
            name: "running"
            PropertyChanges{target: busyIndicator; visible: true }
        },
        State {
            name: "stopped"
            PropertyChanges{target: busyIndicator; visible: false }
        }
    ]

    Rectangle{id: background; anchors.fill: parent; opacity: 0.9; radius: 8;}

    Text { id: theText;
        text: "";
        y: parent.height/4
        anchors {
            horizontalCenter: parent.horizontalCenter;
        }
        font.pointSize: externalFontSize
        width: parent.width
        height: contentHeight
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Item {
        width: parent.width; height: parent.height-theText.y-theText.height
        anchors.centerIn: theText.text == "" ? parent : undefined
        anchors.bottom: theText.text == "" ? undefined : parent.bottom;
        BusyIndicator { id: busyIndicator; width: wait.height/4; height: width
            anchors.centerIn: parent
        }
    }

    Rectangle { id: button
        width: parent.width
        height: parent.height/5
        anchors {left: parent.left; bottom: parent.bottom}
        Text { anchors.centerIn: parent
            text: buttonText
            font.pixelSize: parent.height/2
        }

        visible: hasButton
        color: "transparent"
        MouseArea { anchors.fill: parent
            onClicked: {
                buttonClicked(callbackData);
            }
        }
        radius: 8;
        border.color: "lightblue"
    }

    Timer{id: redrawTimer; interval: 30
        onTriggered: {callbackAfterForceRedraw()}
    }

    onVisibleChanged: {
        if(visible && typeof(callbackAfterForceRedraw) != "undefined"){
            redrawTimer.start()
        }
    }
}
