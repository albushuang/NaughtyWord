import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2

// yesClicked: function (text)
// noClicked: function (text)
Image { id: interactPic
    property var delegator
    property real hRatio
    property real vRatio
    property alias text: userInput.text
    property bool hasInput: true
    property alias textInput: userInput.textInput
    QtObject { id: own
        property string yesText : qsTr("OK")
        property string noText : qsTr("Cancel")
    }

    height: width*sourceSize.height/sourceSize.width
    source: "qrc:/NWDialog/pic/bgInteract.png"

    state: "onlyTwoButtons"
    states: [
        State { name: "singleConfirm"
            StateChangeScript { script: {
                frameOne.visible = true
                oneText.text = own.yesText
                btnTwo.visible = false
                frameLeft.visible = false
                frameRight.visible = false
                btnOne.anchors.fill = frameOne
                btnOne.source = "qrc:/NWDialog/pic/btnOneConfirm.png"
                hasInput = false
            }}
        },
        State { name: "singleCancel"
            StateChangeScript { script: {
                frameOne.visible = true
                oneText.text = own.noText
                frameLeft.visible = false
                frameRight.visible = false
                btnTwo.visible = false
                btnOne.anchors.fill = frameOne
                btnOne.source = "qrc:/NWDialog/pic/btnOneCancel.png"
                hasInput = false
            }}
        },
        State { name: "inputAndTwoButtons"
            StateChangeScript { script: {
                frameOne.visible = false
                frameLeft.visible = true
                frameRight.visible = true
                btnTwo.visible = true
                btnOne.anchors.fill = frameLeft
                btnTwo.anchors.fill = frameRight
                btnOne.source = "qrc:/NWDialog/pic/btnYes.png"
                btnTwo.source = "qrc:/NWDialog/pic/btnNo.png"
                hasInput = true
            }}
        },
        State { name: "onlyTwoButtons"
            StateChangeScript { script: {
                frameOne.visible = false
                frameLeft.visible = true
                frameRight.visible = true
                btnTwo.visible = true
                btnOne.anchors.fill = frameLeft
                btnTwo.anchors.fill = frameRight
                btnOne.source = "qrc:/NWDialog/pic/btnYes.png"
                btnTwo.source = "qrc:/NWDialog/pic/btnNo.png"
                hasInput = false
            }}
        }
    ]


    TextFieldWithPic { id: userInput
        source: "qrc:/NWDialog/pic/inputBarS.png"
        width: parent.width;
        anchors { top: parent.top; left: parent.left; }
        hShift: 20*hRatio
        vShift: 10*vRatio
        visible: hasInput
        onTextFieldEntered: mouseBtnYes.clicked("");
    }
    Image { id: btnOne }
    Image { id: btnTwo }
    Item { id: frameOne
        height: 97*vRatio; width:472*hRatio
        anchors { bottom: parent.bottom;
            left: parent.left; leftMargin: 4*hRatio
        }
        Text { id: oneText
            anchors { top: parent.top; topMargin: 30*vRatio
                left: parent.left; leftMargin: 230*hRatio }
            text: own.yesText
            color: "white"
            height: 32*vRatio
            verticalAlignment: Text.AlignTop; horizontalAlignment: Text.AlignLeft
            fontSizeMode: Text.VerticalFit; font.pixelSize: 40; font.bold: true
        }
        MouseArea { anchors.fill: parent;
            onClicked: {
                if (interactPic.state=="singleConfirm") {
                    delegator.yesClicked(userInput.text)
                } else {
                    delegator.noClicked(userInput.text)
                }
            }
        }
    }
    Item { id: frameLeft
        height: 89*vRatio; width:237*hRatio
        anchors { bottom: parent.bottom; bottomMargin: 7*vRatio
            left: parent.left; leftMargin: 8*hRatio
        }
        Text {
            anchors { top: parent.top; topMargin: 30*vRatio
                left: parent.left; leftMargin: 123*hRatio }
            text: own.yesText
            color: "white"
            height: 32*vRatio
            verticalAlignment: Text.AlignTop; horizontalAlignment: Text.AlignLeft
            fontSizeMode: Text.VerticalFit; font.pixelSize: 40; font.bold: true
        }
        MouseArea { anchors.fill: parent; id: mouseBtnYes
            onClicked: {
                delegator.yesClicked(userInput.text)
            }
        }
    }
    Item { id: frameRight
        height: 95*vRatio; width:240*hRatio
        anchors { bottom: parent.bottom; left: frameLeft.right; leftMargin: -11*hRatio}
        Text {
            anchors { top: parent.top; topMargin: 30*vRatio
                left: parent.left; leftMargin: 118*hRatio }
            text: own.noText
            color: "white"
            height: 32*vRatio
            verticalAlignment: Text.AlignTop; horizontalAlignment: Text.AlignLeft
            fontSizeMode: Text.VerticalFit; font.pixelSize: 40; font.bold: true
        }
        MouseArea { anchors.fill: parent
            onClicked: {
                delegator.noClicked(userInput.text)
            }
        }
    }
}

