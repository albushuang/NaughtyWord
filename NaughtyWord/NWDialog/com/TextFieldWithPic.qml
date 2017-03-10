import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2

// only works in mobils if Qt5.5.0/5.5/ios/qml/QtQuick/Controls/Styles/Base/TextFieldStyle.qml is revised and no TextFieldStyle is allowed
// for android, modify /Users/albus/Qt5.5.0/5.5/(android_x86)/qml/QtQuick/Controls/Styles/Android/TextFieldStyle.qml, remove styleDef of DrawableLoader, respectively
Item {
    property alias source: inputBar.source
    property alias text: textInput.text
    property int hShift
    property int vShift
    property alias textInput: textInput
    signal textFieldEntered();
    height: width*inputBar.sourceSize.height/inputBar.sourceSize.width
    Image { id: inputBar;
        anchors.fill: parent
        width: 474*parent.width/480; height: width*sourceSize.height/sourceSize.width
        anchors { top: parent.top; left: parent.left; leftMargin: 5*parent.width/480}
    }

    TextField {  id: textInput;
        width: parent.width-hShift*2; height: inputBar.height*0.7
        anchors {
            left: parent.left; leftMargin: hShift
            top: parent.top; topMargin: vShift
        }
        font.pixelSize: height*0.6
        selectByMouse: true
        textColor: "white"
        onAccepted: textFieldEntered();
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
            textInput.style = own.style
        }
    }
}
