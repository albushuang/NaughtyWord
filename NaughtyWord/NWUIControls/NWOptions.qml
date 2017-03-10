import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Window 2.2
import "qrc:/../UIControls"
import "qrc:/generalJS/generalConstants.js" as GeneralConsts

Item { id: root
    width: bg.width //Screen.width > Screen.height ? iFontSize*15 : iFontSize*9;
    height: bg.height //Screen.width > Screen.height ? iFontSize*9 : iFontSize*12
    property alias btn1: btnOne
    property alias btn2: btnTwo
    property alias btn3: btnThree
    property alias btn4: btnFour

    property alias textBtnOne: btnOneText.text
    property alias textBtnTwo: btnTwoText.text
    property alias textBtnThree: btnThreeText.text
    property alias textBtnFour: btnFourText.text

    property alias mouseStealer: mouseStealer

    property int btnNum: 2

    signal btnOneClicked();
    signal btnTwoClicked();
    signal btnThreeClicked();
    signal btnFourClicked();

    //For Background Use
    property bool disableBackgroundMouse: true
    signal backgroundClicked()

    QtObject { id: own
        property int envHeight:1280
        property int shift:42
        property real vRatio: parent.parent.height/envHeight
        function getY(i) {
            var h = bg.height-shift*vRatio
            return shift*vRatio+i*(h/btnNum)
        }
        function getHeight() {
            var h = bg.height-shift*vRatio
            return (h/btnNum)
        }
        function getPictureSouce(){
            switch(btnNum){
            case 2: return "qrc:/pageOption/option2.png";
            case 3: return "qrc:/pageOption/option3.png";
            case 4: return "qrc:/pageOption/option4.png";
            }
        }
    }

    anchors.centerIn: parent
    visible: true;
    clip: !disableBackgroundMouse   //Once clip == true, mouseStealer is useless

    Rectangle{id: background; visible: disableBackgroundMouse
        width: root.parent.width; height: root.parent.height
        x: -root.x; y: -root.y  //Cannot anchors.fill: root.parent
        MouseArea{ id: mouseStealer
            anchors.fill: parent;
            onClicked: {
                backgroundClicked()
            }
        }
        opacity: 0.7; color: "lightgray"
    }

    AutoImage{ id: bg;
        autoCalculateSize: true
        source: own.getPictureSouce();
    }

    Item { id: btnOne
        width: parent.width
        height: own.getHeight()
        x: 0
        y: own.getY(0)
        MouseArea{ anchors.fill: parent
            onClicked: btnOneClicked()
        }
        Text{ id: btnOneText
            anchors{horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin:parent.height/2-height/2.5}
            width: parent.width * 0.8
            height: root.height/8
            //font.pixelSize: hFontSize*1.5
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.VerticalFit
        }
        visible: btnNum >= 1
    }


    Item { id: btnTwo
        width: btnOne.width
        height: btnOne.height
        x: btnOne.x
        y: own.getY(1)
        Text{ id: btnTwoText
            anchors.centerIn: parent
            width: btnOneText.width
            height: btnOneText.height
            //font.pixelSize: btnOneText.font.pixelSize
            color: btnOneText.color
            horizontalAlignment: btnOneText.horizontalAlignment
            verticalAlignment: btnOneText.verticalAlignment
            fontSizeMode: btnOneText.fontSizeMode
        }
        MouseArea{ anchors.fill: parent
            onClicked: btnTwoClicked()
        }
        visible: btnNum >= 2
    }

    Item { id: btnThree
        width: btnOne.width
        height: btnOne.height
        x: btnOne.x
        y: own.getY(2)
        Text{ id: btnThreeText
            //font.pixelSize: btnOneText.font.pixelSize
            color: "white"
            x: parent.width/2-width/2
            y: { var shift = btnNum>3 ? 15*own.vRatio : 0
                 return parent.height/2-height/2-shift }
            width: btnOneText.width
            height: btnOneText.height
            horizontalAlignment: btnOneText.horizontalAlignment
            verticalAlignment: btnOneText.verticalAlignment
            fontSizeMode: btnOneText.fontSizeMode
        }
        MouseArea{ anchors.fill: parent
            onClicked: btnThreeClicked()
        }
        visible: btnNum >= 3
    }

    Item { id: btnFour
        width: btnOne.width
        height: btnOne.height
        x: btnOne.x
        y: own.getY(3)
        MouseArea{ anchors.fill: parent
            onClicked: btnFourClicked();
        }
        Text{ id: btnFourText
            text: GeneralConsts.txtCancel
            //font.pixelSize: btnOneText.font.pixelSize
            x: parent.width/2-width/2
            y: { var shift = btnNum*7*own.vRatio
                return parent.height/2-height/2-shift }
            color: btnOneText.color
            horizontalAlignment: btnOneText.horizontalAlignment
            verticalAlignment: btnOneText.verticalAlignment
            fontSizeMode: btnOneText.fontSizeMode
        }
        visible: btnNum >= 4
    }
}

