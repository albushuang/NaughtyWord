import QtQuick 2.0
import "qrc:/generalJS/generalConstants.js" as GeneralConsts
//TODO Shadow: Change this to make it prettier
Item {
    signal backToMenuClicked()
    property alias log: logBlock.text
    width: parent.width * 0.5
    height: parent.height * 0.5
    anchors.centerIn: parent

    Rectangle{
        width: parent.width; height: parent.height
        anchors.centerIn: parent
        border {color: "#CC9900";  width: 7}

        color: "#CC00FF"
        gradient: Gradient {
            GradientStop { position: 1.0; color: "lightsteelblue" }
            GradientStop { position: 0.0; color: "blue" }
        }
        Text {
            id: logBlock
            text: ""
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
            width: parent.width * 0.35; height: parent.height * 0.2
            x: parent.x + parent.width/2 - width/2; y: parent.y + parent.height * 0.65
            color: "orange"
            radius: 5
            Text{
                width: parent.width -5; height: parent.height -5
                anchors.centerIn: parent
                text: GeneralConsts.txtConfirm
                font.pixelSize: 500
                fontSizeMode: Text.Fit
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    backToMenuClicked()
                }
            }
        }

    }

}

