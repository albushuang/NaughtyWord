import QtQuick 2.4
import com.glovisdom.UserSettings 0.1
import "qrc:/NWDialog"

Item { id: termsWindow
    property var deleteLater
    property var langConvert
    anchors.fill: parent
    Rectangle { anchors.fill: parent
        color: "white"
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: parent
    }
    Rectangle {
        anchors.centerIn: parent
        width: terms.contentWidth
        height: terms.contentHeight
        Text { id: terms
            text: qsTr("User Terms")
            font.pointSize: 30
        }
        color: "yellow"
        opacity: 0.8
        MouseArea { anchors.fill: parent; onClicked: { dialog.visible = true }}
    }
    property string userTerms: qsTr(
            "Thanks for choosing “Naughty Word”. Our user terms are as short as possible for providing information to optimize the user experience we offer.<br>
             According to this agreement, when you hit “OK” button, you will have granted us (1) to provide advertising and other information to you, (2) to provide “ glövisdom Inc.” user “Feedback”, including search results, interested contents of “Naughty Word”, you acknowledge that the “Feedback” is not confidential and not related to privacy, and you authorize “glövisdom Inc.” to use that “Feedback” without restriction and without payment to you, (3) to push your game score to our leader boardand (4) wish you have a good time.")
    NWDialog { id : dialog
        width: parent.width*0.8
        delegator: own
        state: "onlyTwoButtons"
        title: qsTr("User terms")

        Flickable {
            width: dialog.width*0.85
            height: dialog.height*0.42
            contentHeight: termsText.contentHeight
            anchors.top: dialog.messageObj.top
            anchors { horizontalCenter: parent.horizontalCenter }
            Text { id: termsText
                width: parent.width
                text:userTerms
                font.pointSize: 20
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                color: "white"
            }
            clip: true
        }
    }


    QtObject { id: own
        function noClicked() {
            dialog.visible = false
        }
        function yesClicked() {
            UserSettings.termsAccepted = true
            UserSettings.lastAppVersion = UserSettings.thisAppVersion
            deleteLater(termsWindow)
        }
    }
}


