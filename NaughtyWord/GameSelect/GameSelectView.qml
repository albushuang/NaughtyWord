import QtQuick 2.4
import QtQuick.Controls 1.3
import "qrc:/../../UIControls"
import "viewConsts.js" as Consts

Item { id: view
    property var delegator
    property ListModel studyModel
    property var modelDatas
    property int titleLv: 0
    property int cellPicWidth: 740
    property int cellPicHeight: 287

    property alias gameListModel: games.model
    property alias gamesView: games

    Image {
        source: "qrc:/pic/background0.png"
        anchors.fill: parent
    }

    AutoImage {
        source: "qrc:/pic/NW_GamePage_top image.png"
        y: 102*vRatio; z:1
    }

    ListView { id: games
        width: 690*hRatio; height: 785*vRatio
        anchors.horizontalCenter: parent.horizontalCenter
        y: 390*vRatio
        spacing: 7*vRatio
        delegate: gameDelegate
        clip: true
        currentIndex: -1
        highlightFollowsCurrentItem: false

        Component { id: gameDelegate
            Rectangle { id: gameRect; width: theButton.width; height: theButton.height
                anchors.horizontalCenter: parent.horizontalCenter
                Image { id: theButton;
                    width: 1100*view.width/1242;
                    height: 295*view.height/2208;
                    source: imageUrl
                    anchors.centerIn: parent
                }
                Text { id: theText; color:"white"; text: name
                    x: diamond ? 175*hRatio : 150*hRatio ; y: 50*vRatio;
                    width: 400*hRatio; height:80*vRatio
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.min(70*vRatio, 70*hRatio)  //Maximum 6 chinese characters, each 70x70
                    fontSizeMode: Text.HorizontalFit
                }
                Image {
                    width: 236*0.7*view.width/1242;
                    height:231*0.7*view.height/2208;
                    source: "qrc:/pic/gameSelect_diamond.png"
                    anchors{left: parent.left; leftMargin: 47*hRatio; verticalCenter: parent.verticalCenter}
                    visible: diamond
                }
                MouseArea { id: cellMouse;
                    anchors.fill: theButton
                    onClicked: {
                        games.currentIndex = index
                        delegator.clickOnCell(gameId);
                    }
                }
                color: "transparent"
            }
        }
    }


    AutoImage{id: remainsBar;
        width:parent.width;height: 85*vRatio;
        anchors{bottom: parent.bottom; bottomMargin: 20*vRatio;}
        source: "qrc:/pic/Practice_Remain Blue bar.png"

        AutoImage{id: titleImg;
            source: "qrc:/scoreTitleSlim.png"

            anchors{bottom: remainsBar.top; bottomMargin: -3*vRatio; horizontalCenter: parent.horizontalCenter}
            Text {id: titleText
                property bool isMainTitle: true
                x: parent.width*72/336; y: parent.height*21/109
                width: parent.width*235/336;height: parent.height*68/109
                text: qsTr("Title: %1").arg(Consts.titles[titleLv])
                font.bold: isMainTitle ? true : false;
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                font.pixelSize: nFontSize; minimumPixelSize: 3
                fontSizeMode: Text.Fit
                color: "#ffcc66"
                onIsMainTitleChanged: {
                    if(isMainTitle){ text = qsTr("Title: %1").arg(Consts.titles[titleLv])}
                    else{
                        text = titleLv < Consts.titles.length - 1 ?
                                    qsTr("Promotion:\n  Mastered over %1 cards").arg(Consts.lvUpCriteria[titleLv]) :
                                    qsTr("Best title")
                    }
                }
            }
            AutoImage{id: arrow
                source: "qrc:/gameSelect_white arrow.png"
                anchors{right: parent.right; rightMargin: 2*hRatio; verticalCenter: parent.verticalCenter}
                width: 30*hRatio; height: 30*vRatio
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    flipBackTimer.stop()
                    titleText.isMainTitle = !titleText.isMainTitle
                }
                onReleased: { flipBackTimer.restart() }
                Timer{id: flipBackTimer; interval: 2500; onTriggered: {titleText.isMainTitle = true}}
            }
        }

        ListView{id: remainsListView
            anchors.fill: parent
            delegate: remainsDelegate
            model: studyModel
            snapMode: ListView.SnapOneItem;
            orientation: ListView.Horizontal
            highlightMoveDuration: 600
            interactive: false
            clip: true
            onCountChanged:{
                if(count > Consts.defaultItemIdex){
//                    currentIndex = Consts.defaultItemIdex
                    /*Weird bug: setting currentIndex is still too early even count > targetIndex. Use
                    a very small timer to work around*/
                    wordAroundTimer.start()
                }
            }
            Timer{id: wordAroundTimer; interval: 30; onTriggered: {
                    remainsListView.highlightMoveDuration = 0
                    remainsListView.currentIndex = Consts.defaultItemIdex
                    remainsListView.highlightMoveDuration = 600
                }
            }
        }
        Timer{id: toMiddleTimer; interval: 5000; onTriggered: {remainsListView.currentIndex = Consts.defaultItemIdex}}
        AutoImage{
            id: leftArrow; rotation: 180
            source: "qrc:/gameSelect_white arrow.png"
            anchors{left: parent.left; leftMargin: 5*hRatio; verticalCenter: parent.verticalCenter}
            visible: remainsListView.currentIndex != 0 || onPressing
            property bool onPressing: false
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    leftArrow.onPressing = true
                    toMiddleTimer.stop()
                    remainsListView.currentIndex = Math.max(0,remainsListView.currentIndex-1)
                }
                onReleased: {toMiddleTimer.restart(); leftArrow.onPressing = false}
            }
        }
        AutoImage{
            id: rightArrow
            source: "qrc:/gameSelect_white arrow.png"
            anchors{right: parent.right; rightMargin: 12*hRatio; verticalCenter: parent.verticalCenter}
            visible: remainsListView.currentIndex != remainsListView.count - 1 || onPressing
            property bool onPressing: false
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    rightArrow.onPressing = true
                    toMiddleTimer.stop()
                    remainsListView.currentIndex = Math.min(2,remainsListView.currentIndex+1)
                }
                onReleased: {toMiddleTimer.restart(); rightArrow.onPressing = false}
            }
        }
    }

    Component{id: remainsDelegate
        Item{
            width: remainsBar.width; height: remainsBar.height
            Text{id: deckText; color: "white"
                anchors{horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 10*vRatio}
                width: Math.min(contentWidth, parent.width - 50*hRatio); height: 36*vRatio
                text: typeof(modelDatas[itemKey].deckName) != "undefined" ? modelDatas[itemKey].deckName: ""
                font.pointSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
            }
            Text{id: remainsText; color:"#e8cc5f"
                anchors{horizontalCenter: parent.horizontalCenter; top: deckText.bottom; topMargin: 0*vRatio}
                width: Math.min(contentWidth, parent.width - 50*hRatio); height: 30*vRatio
                text: composeDisplayStr()//txtArr.displayStr[index]
                font.pointSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
                function composeDisplayStr(){
                    var thisItems = modelDatas[itemKey].items
                    var disTxt = ""
                    if(thisItems.length > 0){ disTxt += thisItems[0].item + ": " + thisItems[0].value }

                    for(var i = 1; i < thisItems.length; i++){
                        disTxt += "   " + thisItems[i].item + ": " + thisItems[i].value
                    }

                    return disTxt
                }
            }
        }

    }


}


