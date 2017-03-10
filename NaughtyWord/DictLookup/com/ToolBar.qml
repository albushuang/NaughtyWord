import QtQuick 2.5
import "qrc:/../../UIControls"

Item { id: toolbar
    property alias button1: button1
    property alias button2: button2
    property alias button3: button3
    property real hRatio
    property real vRatio
    property bool asynchronous
    property string which: "main"

    ImgButton2Function { id: button1
        state: which
        anchors { bottom: parent.bottom;
            left: parent.left; leftMargin: 18*hRatio;
        }
        asynchronous: toolbar.asynchronous
    }

    ImgButton2Function { id: button2
        state: which
        anchors { bottom: parent.bottom;
            left: button1.right; leftMargin: 18*hRatio;
        }
        asynchronous: toolbar.asynchronous
    }

    ImgButton { id: button3
        anchors { bottom: parent.bottom; bottomMargin: 20*vRatio
            right: parent.right; rightMargin: 18*hRatio;
        }
        asynchronous: toolbar.asynchronous
    }
}
