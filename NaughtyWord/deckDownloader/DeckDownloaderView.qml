import QtQuick 2.0
import "qrc:/../../UIControls"
import "../DictLookup/com"




/*Currently, this view is not used. Just keep the code if we want to use it someday.
This view is designed as deckSelection but for deck downloader*/






Item {id: root
    property var delegator
    property alias cateModel: categoryView.model
    property alias decksModel:decksView.model
    property alias currentIndex: decksView.currentIndex

    signal categoryClicked(string settingKey, int index, bool isOn)
    signal deckClicked(string fileName, int index)
    signal dlClicked()

    width: background.width+30*hRatio; height: background.height
    anchors.centerIn: parent

//    AutoImage{id: background
//        x:34*hRatio; y:0
////        scale:1.7
//        source: "qrc:/pic/NW_GamePage_Deck bg_plain.png"
//        MouseArea{ anchors.fill:parent } //work as mouse stealer
//    }
    Rectangle{id: background; //738 1761
        anchors.centerIn: parent; color: "#417195"
        width: 738*stackView.width/1242; height: 1761*stackView.height/2208
        scale: 1.5//scale will not change width/height, so we can keep old art design
    }

    GridView{id: categoryView
//        x: 60*hRatio; y: 0*vRatio
        anchors{horizontalCenter: parent.horizontalCenter}
        width: 407*hRatio; height: 338*vRatio
        cellWidth: iconImgWidth + 10*hRatio;
        cellHeight: categoryView.iconImgHeight + iconTextHeight
        delegate: cellDelegate
        property real iconImgWidth: 96*hRatio
        property real iconImgHeight: 90*vRatio
        property real iconTextHeight: 37*vRatio

        Component{id: cellDelegate
            Item{id: iconItem
                width: categoryView.iconImgWidth;
                height: categoryView.iconImgHeight + iconText.height
                AutoImage{id: iconImg
                    x:40*hRatio; y:40*vRatio
                    width: categoryView.iconImgWidth ;
                    height: categoryView.iconImgHeight
                    source: "qrc:/pic/" + (isFilterOn ? imgSrcOn : imgSrcOff)
                }
                Text{id: iconText; text: txt; color: "white"
                    anchors{left: iconImg.left; top: iconImg.bottom}
                    width: iconImg.width; height: categoryView.iconTextHeight
                    font.pixelSize: 16; fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                MouseArea{ anchors.fill: iconImg; onClicked: {
                    categoryClicked(key, index, !isFilterOn)}
                }
            }
        }
    }

    AutoImage{id: line
        anchors.horizontalCenter: background.horizontalCenter
        anchors.verticalCenter: arrow.verticalCenter
        source: "qrc:/pic/NW_GamePage_Deck bg_Line.png"
    }

    AutoImage { id: arrow
//        source: "qrc:/DictLookup/pic/NW_GamePage_deck button.png"
        source: "file:/Users/yuanchunwu/Downloads/art design/NW_GamePage_deck button2.svg"
        mirror: false
        width: 74; height:66
        anchors{horizontalCenter: line.horizontalCenter}
//        x : -28*hRatio
        y: 298*vRatio
        MouseArea{anchors.fill: parent
            onClicked: { dlClicked()}
        }
        Text{
            anchors{top: parent.top; bottom: parent.bottom; right: parent.right; left:parent.left; margins: 15*hRatio}
            text: qsTr("Download")
            color: "white"
            fontSizeMode: Text.Fit; minimumPixelSize: 3
            font.pixelSize: 22; font.bold: true
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
            renderType:Text.NativeRendering
        }
    }

    ListView{id: decksView
        width: cellWidth + 2*decksView.highlightBorder; height: 650*vRatio
        /*x: 85*hRatio;*/ y: 400*vRatio
        anchors{horizontalCenter: parent.horizontalCenter}
        delegate: decksDelegate
        highlight: highlight
        clip: true
        property real highlightBorder: 3.2*hRatio
        property real cellWidth: 340*hRatio
        property real cellHeight: 80*vRatio
        Component{id: decksDelegate
            Item{ id: decksDelegateItem
                width: cellBackground.width + 2*decksView.highlightBorder
                height: cellBackground.height + 2*decksView.highlightBorder
                AutoImage{id: cellBackground
                    x: decksView.highlightBorder; y: decksView.highlightBorder
                    width: decksView.cellWidth; height: decksView.cellHeight
                    source: delegator.getImgBackground(fileName.substr(fileName.length-4,4))
                }
                MouseArea{id: cellMouse
                    anchors.fill: parent
                    onClicked:{
                        deckClicked(fileName, index)
                    }
                }

                FlickableText{id: deckName; color: "white"                    
                    text: fileName.replace(/\..*/, "")
                    width: 230*hRatio; height: 45*vRatio
                    x: 95*hRatio; y:10*vRatio //anchors{verticalCenter: parent.verticalCenter}
                    font.pixelSize: fontTooBig; textObj.fontSizeMode: Text.VerticalFit
                    textMouse.onReleased: {//For iphone 3D touch bug, we need to implement onClicked by ourselves.
                        if(!textMouse.drag.active){
                            deckClicked(fileName, index)
                        }
                    }
                }

                Text{id: dlStatus;
                    color: "white"
                    text: downloadStatus
                    anchors{top: deckName.bottom;}
                    width: deckName.width; height: 18*vRatio
                    font.pixelSize: fontTooBig; fontSizeMode: Text.VerticalFit
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    x: deckName.x
                }

                Rectangle{ id: highlightRec; color:"transparent";
                    anchors.fill: parent; radius: 5;
                    border{color: "white"; width: decksView.highlightBorder}
                    visible: isClicked
                }
            }
        }

    }
}

