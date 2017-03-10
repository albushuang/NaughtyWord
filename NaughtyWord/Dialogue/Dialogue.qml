import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import "qrc:/../UIControls"
import "../generalJS/generalConstants.js" as GeneralConsts

Item { id: dialog;
    width: Screen.width > Screen.height ? iFontSize*15 : iFontSize*9;
    height: Screen.width > Screen.height ? iFontSize*9 : iFontSize*12
    property alias caption: caption
    property alias titleText: titleText
    property string title
    property bool hasTwoBtn: true
    property bool hasInput: true
    property string btn1Text: GeneralConsts.txtConfirm
    property string btn2Text: GeneralConsts.txtCancel
    property bool disableBackgroundMouse: true

    signal confirmed(Item thisObj, string action, string userInput);
    signal cancelled();
    signal backgroundClicked()

    Item{id: mouseStealer; visible: disableBackgroundMouse
        width: dialog.parent.width; height: dialog.parent.height
        x: -dialog.x; y: -dialog.y  //Cannot anchors.fill: dialog.parent
        MouseArea{ anchors.fill: parent;
            onClicked: {
                if(hasInput){ input.focus = false }
                backgroundClicked()}
        }
    }
    Rectangle{anchors.fill: bg} //The original image (scoreBG.png) has low opacity. Add white background
    AutoImage {id: bg; anchors.fill: parent; autoCalculateSize: false
        source: "qrc:/pic/scoreBG.png";
    }

    anchors.centerIn: parent
    visible: false; clip: !disableBackgroundMouse   //Once clip == true, mouseStealer is useless

    Text { id: titleText; color: "#336699"
        width: parent.width - 38; height: text == "" ? 0 : contentHeight  //It'd better to assign height instead of undefined
        anchors { top: parent.top; topMargin: 30*vRatio; horizontalCenter: parent.horizontalCenter}
        font.pixelSize: hFontSize; wrapMode: Text.WordWrap; fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignHCenter;
        text: title
    }

    Text { id: caption; color: "#336699"; width: parent.width- 38;
        anchors { top: titleText.bottom; topMargin: 10; bottom: input.top; bottomMargin: 10
            horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        font.pixelSize: iFontSize; wrapMode: Text.WordWrap; fontSizeMode: Text.Fit
    }

    // for Android change:
    // Qt5.5.0/5.5/android_x86/qml/QtQuick/Controls/Private/EditMenu.qml, and:
    // Qt5.5.0/5.5/android_armv7/qml/QtQuick/Controls/Private/EditMenu.qml, load EditMenu_ios.qml instead of
    // loading nothing...

        TextField { id: input;
            anchors { bottom: btnOK.top; bottomMargin: 10; horizontalCenter: parent.horizontalCenter }
// enable style causes "Copy/Paste" failed!
//            style: TextFieldStyle {
//                selectedTextColor: "#ffcc66"
//                background: Rectangle {
//                    color: "transparent"
//                }
//            }
            width: parent.width*0.85; height: input.font.pixelSize*6/4;
            //height: parent.height; width: parent.width*0.9
            anchors.centerIn: parent
            font.pixelSize: iFontSize
            maximumLength: 256
            focus: dialog.visible; selectByMouse: true; clip: true;
            visible: hasInput
            onAccepted: btnOKMouse.clicked("")
        }

    AutoImage { id: btnOK; width: parent.width*138/1381; height: width*rawHeight/rawWidth; clip: true
        anchors { bottom: parent.bottom; bottomMargin: parent.height*65/1494
            left: parent.left;  leftMargin: hasTwoBtn ? parent.width*444/1381 : parent.width/2-width/2}
        source: "qrc:/pic/buttonOK.png"
        MouseArea { anchors.fill: parent; id: btnOKMouse
            onClicked: {
                dialog.visible = false
                confirmed(dialog, title, input.text)
                if(hasInput){ input.focus = false }
            }
        }
    }

    AutoImage { id: btnCancel; width: parent.width*138/1381; height: width*rawHeight/rawWidth; clip: true
        anchors { bottom: parent.bottom; bottomMargin: parent.height*65/1494
                  right: parent.right;  rightMargin: parent.width*444/1381}
        source: "qrc:/pic/scoreBack.png"
        MouseArea { anchors.fill: parent;
            onClicked: {
                dialog.visible = false
                cancelled();
                if(hasInput){ input.focus = false }
            }
        }
        visible: hasTwoBtn
    }

    function show(text) {
        caption.text = text;
        if(hasInput){
            input.focus = false
            input.forceActiveFocus()
        }
        dialog.visible = true;
    }

    function setInputText(text) {
        input.text = text;
    }
}
