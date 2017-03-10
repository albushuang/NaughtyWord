import QtQuick 2.4
import QtQuick.Controls 1.3
import com.glovisdom.UserSettings 0.1
import "com"

// yesClicked: function (text)
// noClicked: function (text)
//  type: onlyTwoButtons,inputAndTwoButtons, singleCancel, singleConfirm
Item { id: dialog
    property var delegator
    property alias hasInput: interactItem.hasInput
    property alias title: titleText.text
    property alias message: messageText.text
    property alias textInput: interactItem.textInput
    property alias messageObj: messagePic
    height: titlePic.height+messagePic.height+interactItem.height
    anchors.centerIn: parent

    function setMessageHeight(height) {
        message.height = height
    }
    function setInputText(text) {
        interactItem.text = text
    }

    Image { id: titlePic
        anchors {top: parent.top; left: parent.left}
        source: "qrc:/NWDialog/pic/bgTitle.png"
        width: parent.width; height: width*sourceSize.height/sourceSize.width
        Image { id: titleBar
            source: "qrc:/NWDialog/pic/titlebar.png"
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
            width: parent.width*414/480; height: width*sourceSize.height/sourceSize.width
        }
        Text { id: titleText
            anchors { horizontalCenter: parent.horizontalCenter;
                bottom: parent.bottom; bottomMargin: 30*parent.height/345
            }
            color: "white"
            height: 60*vRatio
            width: parent.width*0.75
            fontSizeMode: Text.Fit
            wrapMode: Text.Wrap
            font.pixelSize: 40
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Image { id: messagePic
        anchors {top: titlePic.bottom; left: parent.left}
        source: "qrc:/NWDialog/pic/bgMessage.png"
        width: parent.width; height: width*sourceSize.height/sourceSize.width
        Text { id: messageText
            width: parent.width*0.8; height: parent.height*0.8
            anchors.centerIn: parent
            color: "white"
            font.pointSize: UserSettings.fontPointSize
            wrapMode: Text.Wrap
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
        }
    }
    InputAndButtons { id: interactItem
        hRatio: own.hRatio; vRatio: own.vRatio
        delegator: dialog.delegator
        anchors {top: messagePic.bottom; left: parent.left}
        width: parent.width;
        state: parent.state
    }

    QtObject { id: own
        property real hRatio: dialog.width/480
        property real vRatio: dialog.height/808
        function checkCallback(callback) {
            if(typeof(callback)!="undefined") { callback() }
        }
    }
}
