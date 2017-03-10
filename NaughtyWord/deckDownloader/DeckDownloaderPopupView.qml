import QtQuick 2.0
import "qrc:/../../UIControls"
import "../DictLookup/com"

Item {id: root
    property var delegator
    property alias cateModel: categoryView.model
    property alias decksModel:decksView.model
    property alias currentIndex: decksView.currentIndex

    signal categoryClicked(string settingKey, int index, bool isOn)
    signal deckClicked(string fileName, int index)
    signal dlClicked()

    width: background.width+30*hRatio; height: background.height
    anchors{ horizontalCenter: parent.horizontalCenter}

    Rectangle{id: background; color: "#417195"
         anchors{bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
        width: decksView.width + 66*hRatio; height: decksView.height + 239*vRatio
        radius: 15*hRatio
    }

    GridView{id: categoryView
        anchors{horizontalCenter: parent.horizontalCenter}
        width: 407*hRatio; height: 338*vRatio
        cellWidth: iconImgWidth + 10*hRatio;
        cellHeight: categoryView.iconImgHeight + iconTextHeight
        delegate: cellDelegate
        property real iconImgWidth: 96*hRatio
        property real iconImgHeight: 90*vRatio
        property real iconTextHeight: 37*vRatio
        visible: false

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
    Text { id: titleText; color: "white"
        text: qsTr("Please select more decks to download")
        anchors { bottom: titleImg.top; bottomMargin: -8*vRatio; horizontalCenter: parent.horizontalCenter}
        width: titleImg.width*0.8; height: 66*vRatio
        fontSizeMode: Text.Fit;  wrapMode: Text.Wrap
        font.pixelSize: fontTooBig
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    AutoImage{id: titleImg
        source: "qrc:/NWDialog/pic/titlebar.png"
        anchors{bottom: dlBtn.top; bottomMargin: 0*vRatio; horizontalCenter: parent.horizontalCenter}
        width: 415*hRatio; height: 47*vRatio
    }

    AutoImage { id: dlBtn
        source: "qrc:/deckDownloader/pic/deckDownloader_download_btn.png"
        mirror: false
        width: 95*hRatio; height:84*vRatio
        anchors{horizontalCenter: parent.horizontalCenter}
        anchors{bottom: decksView.top; bottomMargin: 10*vRatio}
        MouseArea{anchors.fill: parent
            onClicked: { dlClicked()}
        }
        Text{id: dlText;
            anchors{top: dlBtn.top; bottom: dlBtn.bottom; right: dlBtn.right; left:dlBtn.left; margins: 10*hRatio}
            text: qsTr("Download"); color: "white"
            fontSizeMode: Text.Fit; minimumPixelSize: 3
            font.pixelSize: fontTooBig; font.bold: true
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
        }
    }


    ListView{id: decksView
        width: cellWidth + 2*decksView.highlightBorder;
        height: Math.min(675*vRatio, count*(cellHeight + 2*decksView.highlightBorder) + decksView.highlightBorder)
        anchors{horizontalCenter: parent.horizontalCenter; bottom: parent.bottom}
        delegate: decksDelegate
        clip: true
        property real highlightBorder: 3.8*hRatio
        property real cellWidth: 451*hRatio
        property real cellHeight: 106*vRatio
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
                        currentIndex = index
                        deckClicked(fileName, index)
                    }
                }

                FlickableText{id: deckName; color: "white"
                    text: fileName.replace(/\..*/, "")
                    width: 305*hRatio; height: 50*vRatio
                    x: 131*hRatio; y:18*vRatio //anchors{verticalCenter: parent.verticalCenter}
                    font.pixelSize: fontTooBig;
                    textMouse.onClicked: {  //FlickableText has a MouseArea to handle flickable. Need to pass it's clicked control out
                        cellMouse.onClicked("")
                    }
                }

                Text{id: dlStatus;
                    color: "white"
                    text: downloadStatus
                    anchors{top: deckName.bottom;}
                    width: deckName.width; height: 28*vRatio
                    font.pixelSize: fontTooBig; fontSizeMode: Text.VerticalFit
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    x: deckName.x
                }

                Rectangle{ id: highlightRec; color:"transparent";
                    anchors.fill: parent; radius: 7;
                    border{color: "white"; width: decksView.highlightBorder}
                    visible: isClicked
                }
            }
        }

    }
}

