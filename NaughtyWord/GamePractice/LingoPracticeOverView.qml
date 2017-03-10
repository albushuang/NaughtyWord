import QtQuick 2.0

Rectangle{
    id: practiceOverDisplay
    signal backToMenuClicked()
    signal pullInPractice()
    property alias logText: logBlock.text
    property int mode: 0 // 0: Finish practice in a normal way.   1: There is no card to review
    visible: false
    width: parent.width * 0.5; height: parent.height * 0.5
    anchors.centerIn: parent
    border {color: "#CC9900";  width: 7}
    color: "#CC00FF"
    gradient: Gradient {
        GradientStop { position: 1.0; color: "lightsteelblue" }
        GradientStop { position: 0.0; color: "blue" }
    }
    Text {
        id: logBlock
        text: mode == 0 ? qsTr("Congratulation! You've already compeleted today's schedule.") : qsTr("You've already compeleted today's schedule. Do you want to do advance review?");
        width: parent.width; height: parent.height
        anchors {left: parent.left; leftMargin: parent.width * 0.05;
            top: parent.top; topMargin: parent.height * 0.05;
            right: parent.right; rightMargin: parent.width * 0.05
            bottom: parent.bottom; bottomMargin: parent.height * 0.5
        }
        color: "#99CC00"
        font.pixelSize: 300
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        wrapMode: Text.WordWrap

    }
    Rectangle{
        width: parent.width * 0.25; height: parent.height * 0.2
        x: mode == 0 ? parent.width/2 - width/2 : parent.width/3 - width/2;
        y: parent.height * 0.65
        color: "orange"
        radius: 5
        Text{
            width: parent.width -5; height: parent.height -5
            anchors.centerIn: parent
            text: qsTr("OK ")
            font.pixelSize: 500
            fontSizeMode: Text.Fit
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(mode ==0){
                    practiceOverDisplay.backToMenuClicked()
                }else{
                    practiceOverDisplay.pullInPractice()
                    mode = 0
                }
            }
        }
    }

    Rectangle{
        width: parent.width * 0.25; height: parent.height * 0.2
        x: parent.width*2/3 - width/2; y: parent.height * 0.65
        color: "orange"
        radius: 5
        visible: mode == 1
        Text{
            width: parent.width -5; height: parent.height -5
            anchors.centerIn: parent
            text: qsTr("Cancel ")
            font.pixelSize: 500
            fontSizeMode: Text.Fit
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                practiceOverDisplay.backToMenuClicked()
            }
        }
    }
}

