import QtQuick 2.0

Rectangle { id: fadingMessage
    property alias theText: idText
    property real wRatio: 0.8
    property real hRatio: 0.8
    property int life: 3000
    property var faded

    color: "white"; opacity: 0
    anchors.centerIn: parent

    Text { id: idText;
        anchors.centerIn: parent
        width: parent.width*wRatio; height: parent.height*hRatio
        font.pointSize: 24
        color: "blue"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
    }
    NumberAnimation on opacity { id: invisible
        easing.type: Easing.InExpo
        running: false; to: 0; duration: life
    }
    function showAndFade() {
        fadingMessage.opacity = 1
        invisible.start()
    }
    function show() { fadingMessage.opacity = 1 }
    function fade() { invisible.start() }
    onOpacityChanged: {
        if (opacity==0) {
            if(typeof(faded) != "undefined") { faded() }
            fadingMessage.destroy()
        }
    }
}
