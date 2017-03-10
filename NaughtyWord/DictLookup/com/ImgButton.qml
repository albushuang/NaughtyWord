import QtQuick 2.5
import "qrc:/../../UIControls"

AutoImage {
    property var callAtClicked
    MouseArea {
        anchors.fill: parent
        onClicked: {
            callAtClicked();
        }
    }
}
