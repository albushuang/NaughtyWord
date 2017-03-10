import QtQuick 2.4
import QtQuick.Controls 1.3
import "qrc:/../UIControls"
import "../deckManagement"
import "../NWUIControls"

Item { id: view;
    property var delegator;
    property real hRatio: width/750
    property real vRatio: height/1334
    property alias gameArea: leg1
    Image {anchors.fill: parent
        source: "qrc:/pic/background0.png"        
    }

//    MouseArea{ id: shuffleTest
//        width: 250*hRatio;
//        height: 250*vRatio
//        onClicked: {
//            var url = "qrc:/MainPage/ShuffleTest.qml"
//            stackView.vtSwitchControl(url, {}, false, false, true);
//        }
//    }

//    MouseArea{ id: lizardWalkingTest
//        width: 250*hRatio;
//        height: 250*vRatio
//        anchors.right: parent.right
//        onClicked: {
//            var url = "qrc:/MainPage/LizardWalkTest.qml"
//            stackView.vtSwitchControl(url, {}, false, false, true);
//        }
//    }

    AutoImage { id: diamond; source: "qrc:/pic/mainPage_diamond.png"
        x: hRatio*300; y: vRatio*390;
    }

    AutoImage { id: leg1; source: "qrc:/pic/mainPage_leg1.png"
        x: hRatio*128; y: vRatio*403;
        MouseArea { id: dictMouseArea; anchors.fill: parent
            onClicked: {
                delegator.leg1Clicked()
            }
        }
    }

    Text{id: leg1Text
        //: First page. Enter dictionary page
        text: qsTr("Games"); color: "white"
        width:143*hRatio; height:58*vRatio
        x:172*hRatio; y: 445*vRatio
        rotation: 2; font.bold: true
        font.pixelSize: calculateFontPixelSizeForLegs(); fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    AutoImage { id: leg2; source: "qrc:/pic/mainPage_leg2.png"
        x: hRatio*13; y:vRatio*523;
        MouseArea { id: deckManageArea; anchors.fill: parent
            onClicked: {
                delegator.leg2Clicked()
            }
        }
    }


    Text{id: leg2Text
        //: First page. Enter deck management
        text: qsTr("Dictionary"); color: "white";
        width:215*hRatio; height:52*vRatio
        x:83*hRatio; y: 584*vRatio
        rotation: 6; font.bold: true
        font.pixelSize: calculateFontPixelSizeForLegs(); fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }


    AutoImage { id: leg3; source: "qrc:/pic/mainPage_leg3.png"
        x: hRatio*100; y:vRatio*708;
        MouseArea { id: gameMouseArea; anchors.fill: parent
            onClicked: {
                delegator.leg3Clicked()
            }
        }
    }

    Text{id: leg3Text
        //: First page. Enter game selection view
        text: qsTr("Settings"); color: "white"
        //text: qsTr("Check Deck");
        width:168*hRatio; height:52*vRatio
        x:160*hRatio; y: 728*vRatio
        rotation: -6; font.bold: true
        font.pixelSize: calculateFontPixelSizeForLegs(); fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    AutoImage { id: lizard; source: "qrc:/pic/mainPage_lizard.png"
        x: hRatio*368; y: vRatio*488;
        MouseArea {
            anchors.fill: parent
            onClicked: {
                delegator.about()
            }
        }
    }
    AutoImage { id: grass; source: "qrc:/pic/mainPage_grass.png"
        x: 0; y: vRatio*1122;
        MouseArea{
            property bool pressHold: false
            property point pressPoint
            anchors.fill: parent
            onPressed: { pressHold = false; pressPoint = Qt.point(mouse.x, mouse.y); }
            onPressAndHold: { pressHold = true  }
            onReleased: {
                if(pressHold && Math.abs(mouse.y - pressPoint.y) < 20 && mouse.x - pressPoint.x > 200){
                    delegator.callEngineeringMode()
                }
            }
        }
    }


    function constructFinished(){}//Create empty function to avoid error

    function calculateFontPixelSizeForLegs(){
        //1.72 is the convertion ratio between character width and pixel size
        var pixelSize1 = leg1Text.width/leg1Text.text.length*1.72
        var pixelSize2 = leg2Text.width/leg2Text.text.length*1.72
        var pixelSize3 = leg3Text.width/leg3Text.text.length*1.72
        return Math.min(pixelSize1,pixelSize2,pixelSize3)
    }
}


