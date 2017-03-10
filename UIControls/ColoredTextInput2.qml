import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2


Rectangle {
    property alias inputText: inputText
    property alias hintingText: hintingText
    property alias text: inputText.text
    property alias clearBtnSource: btnImage.source
    property alias hintingTextColor: hintingText.color
    property string styleColor
    property int margin: 5;
    property bool readonly: false

    signal returnPressed()  //This signal is added for iOS because main.qml cannot receive Keys event due to unknown resason
    signal userClear();
    width: 200; height: 62
    color: styleColor

    TextField { id: inputText
        width: parent.width-btnClear.width-margin*3; height: parent.height
        textColor: "#151515"
        maximumLength: 256
        anchors { left: parent.left; leftMargin: margin;
            top: parent.top; topMargin:3;
            bottom: parent.bottom; bottomMargin:0}
        focus: true; selectByMouse: true
        onAccepted: returnPressed()
        //Keys.onReturnPressed: {returnPressed()}
        verticalAlignment: Text.AlignVCenter
        readOnly: readonly
        font.pixelSize: parent.height*0.65
        style: TextFieldStyle {
            selectedTextColor: "#ffcc66"
            background: Rectangle {
                color: "transparent"
            }
        }
    }

    QtObject { id: own
        property Component style: TextFieldStyle {
            background: Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
        }
    }
    Component.onCompleted: {
        if (Qt.platform.os === "windows" || Qt.platform.os === "osx" ||
            Qt.platform.os === "linux" || Qt.platform.os === "unix") {
            inputText.style = own.style
        }
    }

    Button { id: btnClear
        height: parent.height; width: parent.height;
        AutoImage { id: btnImage
            height: parent.height; width: parent.width;
            fillMode: Image.PreserveAspectFit
        }
        anchors { right: parent.right; rightMargin:margin}
        style: ButtonStyle {
            background: Rectangle { border.width: 0; color: styleColor
                        radius: 2
            }
        }
        visible: (inputText.text != "" && !readonly);
        onClicked: {
            inputText.text = "";
            inputText.focus = false
            inputText.forceActiveFocus();
            userClear();
        }
    }

    Text { id: hintingText;
        visible: (inputText.text == "");
        //: The hint message inside dictionary search bar
        text: qsTr("search word")
        font.pixelSize: inputText.font.pixelSize
        color: "lightgrey"
        anchors { left: parent.left; leftMargin: margin;
            verticalCenter: parent.verticalCenter
        }
        verticalAlignment: Text.AlignVCenter
    }
    clip: true;
}

