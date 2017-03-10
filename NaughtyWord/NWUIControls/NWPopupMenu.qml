import QtQuick 2.0
import "qrc:/../UIControls"

/*__________Brief indroduction of using this qml____________________
Properties:
    menuModel: ListModel //[Mandatory]  ListElement{id: int, display: string}
    currentIndex: int //[Optional]
    width: real //[Optional]
    height: real //[Optional]
    enumDirection: readonly Enum (enumDirection.up || enumDirection.down || enumDirection.left || enumDirection.right)
Signal:
    itemClicked(int id, int index)
    backgroundClicked()
Methods:
    show(direction) //direction's type is enumDirection
    end() //Use the direction in show(). No need to assign again
    property ListModel menuModel

*/
PopUpMenu{
    property int fontSize:20
    Image { source: "qrc:/pic/popup_bg.png"
        width: parent.width; height: parent.height+4
        z: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    id: root;
    menuDelegate: theDelegate
    spacing: 0
//TODO Shadow: make this fit naughtyWord style
    Component { id: theDelegate
        Item { id: theItem
            width: root.width; height: 72*vRatio;
            Rectangle{anchors.fill: parent; color: "transparent"}
            Text {text: display;
                anchors {left: parent.left; top: parent.top; bottom: parent.bottom; right: parent.right; leftMargin: 20;
                    topMargin: 3; bottomMargin: 3
                }
                font.pointSize: fontSize; fontSizeMode: Text.FixedHeight
                horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
            }
            Rectangle { id: line1; width: root.width-12;height: 1; color: "white";
                anchors { bottom: theItem.bottom; bottomMargin: 0; left: parent.left; leftMargin: 6}
                visible: index != menuModel.count-1;
            }
            MouseArea { anchors.fill: parent;
                onClicked: {
                    end()
                    itemClicked(id, index);
                }
            }
        }
    }
    function modelElement(actionId, display) {
        this.id = actionId;
        this.display = display;
    }

//    highlight: nwHighlight
//    Component {
//        id: nwHighlight
//        Rectangle {
//            color:{
//                Qt.platform.os === "windows" || Qt.platform.os === "osx" ||
//                Qt.platform.os === "linux" || Qt.platform.os === "unix" ? "lightsteelblue" : "transparent"
//            }
//        }
//    }
}

