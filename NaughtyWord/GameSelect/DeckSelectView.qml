import QtQuick 2.0
import "qrc:/../../UIControls"

Item {id: root
    property var delegator
    property alias cateModel: categoryView.model
    property alias decksModel:decksView.model
    property alias currentIndex: decksView.currentIndex
    property alias arrow: arrow  //For tutorial forcusItem
    property alias dlBtn: dlBtn  //For tutorial forcusItem
    property alias decksView: decksView  //For tutorial forcusItem
    signal categoryClicked(string settingKey, int index, bool isOn)
    signal deckClicked(string fileName, int index)
    signal deckArrowClicked()
    signal dlClicked()
    property real arrowInitialX: -84*hRatio
    property real arrowDeckViewX: 4*hRatio
    property real initialX: root.parent.width
    property real deckViewX: root.parent.width - root.width
    property bool viewChange: false

    width: background.width+30*hRatio; height: background.height
    x: initialX; y: 30*vRatio

    function withDrawView() {
        dragMouse.clicked("")
    }

    AutoImage{id: background
        x:34*hRatio; y:0
        source: "qrc:/pic/NW_GamePage_Deck bg_plain.png"
        MouseArea{ anchors.fill:parent } //work as mouse stealer
    }

    MouseArea { id: dragMouse
//        anchors.fill: arrow
        width: arrow.width*1.2; height: arrow.height*1.8; anchors.centerIn: arrow
//        drag.target: root; drag.axis: Drag.XAxis;
//        drag.minimumX: root.parent.width-root.width*1.3; drag.maximumX: root.parent.width - width;
        onClicked: {
            viewChange = true
            prepareAnimateX()
            deckArrowClicked()
        }
        onReleased: {
            if( arrow.x == arrowDeckViewX && root.x > initialX - deckViewX/1.3)
            {
                viewChange = true
            }
            prepareAnimateX()
        }
        NumberAnimation { id: animateX; duration: 500
            target: root
            properties: "x"
            easing {type: Easing.OutBack; }
        }
    }
    function prepareAnimateX(){
        animateX.from = root.x;
        if (viewChange){
            animateX.to = arrow.x == arrowInitialX ? deckViewX : initialX
            viewChange = false
        }
        else{
            animateX.to = arrow.x === arrowInitialX ? initialX : deckViewX
        } 
        animateX.restart()
    }
    onXChanged: {
        arrow.x = root.x == initialX ? arrowInitialX : arrowDeckViewX
        if (dragMouse.drag.active){
            if (root.x>initialX + arrowInitialX){
                root.x = initialX + arrowInitialX
            }
        }
        if (root.x == initialX)
            arrow.mirror = false
        else if (root.x == deckViewX)
            arrow.mirror = true
    }

    AutoImage { id: arrow
        source: "qrc:/pic/NW_GamePage_deck button.png"
        mirror: false
        x: arrowInitialX
        y: root.y + 263*vRatio
        SequentialAnimation{
            loops: Animation.Infinite; running: true
//            NumberAnimation{
////                target: arrow; property: "opacity"
//                target: arrow; property: "rotation"
////                from: 1; to:0.7
//                from: 0; to:180
//                duration: 800
//            }

//            PauseAnimation {
//                duration: 800
//            }
            NumberAnimation{
//                target: arrow; property: "opacity"
                target: arrow; property: "rotation"
//                from: 0.7; to:1
                from: 0; to:360
                duration: 1200
            }
            PauseAnimation {
                duration: 1200
            }
        }
    }

    GridView{id: categoryView
        x: 60*hRatio; y: 0*vRatio
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
    AutoImage { id: dlBtn
        source: "qrc:/deckDownloader/pic/deckDownloader_download_btn.png"
        width: arrow.width*1.1; height: arrow.height*1.1
        anchors.centerIn: line
        MouseArea{anchors.fill: parent
            onClicked: { dlClicked(); dragMouse.clicked("")}
        }
        Text{id: dlText
            anchors{top: parent.top; bottom: parent.bottom; right: parent.right; left:parent.left; margins: 10*hRatio}
            text: qsTr("More\ndecks"); color: "white"
//            width: parent.width * 1.95;
            fontSizeMode: Text.Fit; minimumPixelSize: 3
            font.pixelSize: fontTooBig; font.bold: true
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
        }

    }



    ListView{id: decksView
        width: cellWidth + 2*decksView.highlightBorder; height: 650*vRatio
        x: 85*hRatio; y: 365*vRatio
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

                MouseArea{id: deckMouse; anchors.fill: parent; z: 0
                    onClicked: {
                        decksView.currentIndex = index
                        deckClicked(fileName, index)
                    }
                }
                FlickableText{id: deckName; color: "white"; z:1
                    text: fileName.replace(/\..*/, "")
                    anchors.verticalCenter: cellBackground.verticalCenter
                    width: 224*hRatio; height: 30*vRatio
                    x: 102*hRatio;
                    font.pixelSize: fontTooBig
                    textMouse.onClicked: {  //FlickableText has a MouseArea to handle flickable. Need to pass it's clicked control out
                        deckMouse.clicked("")
                    }
                }
                Component.onCompleted: {
                    if(typeof(delegator.extraAction)!="undefined") {
                        delegator.extraAction(decksDelegateItem, fileName, index)
                    }
                }
            }
        }

        Component{id: highlight
            Rectangle{ // Highlight always fills delegate. This makes x, y, height, width, z useless.
                id: highlightRec
                color:"transparent";
                radius: 5;
                border{color: "white"; width: decksView.highlightBorder}
            }
        }
    }
}

