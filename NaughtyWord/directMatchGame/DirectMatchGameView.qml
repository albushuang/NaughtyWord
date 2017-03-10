import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "ViewSettingsInDirectMatchGame.js" as Settings
import QtQuick.Particles 2.0
import "qrc:/../../UIControls"
import "../generalJS/generalConstants.js" as GeneralConsts
import "settingValues.js" as Value

Item {id:directMatchGameView
    width: parent.width; height: parent.height;
    property int largerSide; property int smallerSide
    property int numOfChoices : largerSide * smallerSide
    property bool isViewWidthShorter: width < height
    property double gridPercentage: Settings.choiceGridPercentae
    property string score
    property string time
    property alias questionBlock: questionBlock
    property alias choiceButtons: choiceButtons
    property alias lifeRatio: timeCountingRedBar.life
    property alias halfCorrectLeftHint: halfCorrectLeftHint
    property alias txthalfCorrectLeftHint: txthalfCorrectLeftHint
    property alias halfCorrectRightHint: halfCorrectRightHint
    property alias txthalfCorrectRightHint: txthalfCorrectRightHint
    property int flipTime
    property int questionType
    property int answerType
    property int theFontSize: {
        if (Qt.platform.os == "osx") return hFontSize
        if (Qt.platform.os != "ios") return pFontSize
        return (pFontSize + fFontSize)/2
    }
    property real cardWidth: 273*hRatio
    property real cardHeight: cardWidth
    property real questionBlockScale: 1.15
    property int newsLen: 0
    property int reviewsLen: 0
    property variant isPracticeMode

    AutoImage{
        autoCalculateSize: false; anchors.fill: parent
        source:"qrc:/pic/background0.png"
    }

    function disableAllCards(color){
        questionBlock.disableCard(color)
        for(var i = 0; i < numOfChoices; i++){
            choiceButtons.itemAt(i).disableCard(color)
        }
    }

    function enableAllCards(){
        questionBlock.enableCard()
        for(var i = 0; i < numOfChoices; i++){
            choiceButtons.itemAt(i).enableCard()
        }
    }
    Column{id: sideInfoContainer; visible: typeof(isPracticeMode) != "undefined"
        anchors{right: parent.right; rightMargin: 18*hRatio; bottom: questionBlock.bottom}
        width: sideInfos.signWidth + sideInfos.infoWidth + sideInfos.widthSpacing
        height: sideInfos.count * (sideInfos.signHeight + sideInfos.heightSpacing)
        spacing: sideInfos.heightSpacing
        Repeater{id: sideInfos
            model: Math.min(signs.length, infos.length)
            property variant signs: isPracticeMode ?
                                        [GeneralConsts.txtTime, GeneralConsts.studied, GeneralConsts.reviewed] :
                                        [GeneralConsts.txtScore, GeneralConsts.txtTime]
            property variant infos: isPracticeMode ?
                                        [time, newsLen, reviewsLen] :
                                        [score, time]
            property real signWidth: 95*hRatio
            property real signHeight: 30*hRatio
            property real infoWidth: 100*hRatio
            property real widthSpacing: 5*hRatio
            property real heightSpacing: 25*hRatio
            Item{
                width: sideInfoContainer.width; height: sideInfos.signHeight
                Text{
                    id: signText; color: "#264aa7"
                    width: sideInfos.signWidth; height: parent.height
                    text: sideInfos.signs[index].toString()
                    font.pixelSize: fontTooBig; fontSizeMode: Text.Fit; minimumPixelSize: 3
                    horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter
                }
                AutoImage{
                    id: text_BG
                    autoCalculateSize: false;
                    source:"qrc:/pic/directMatchGame_ score bar.png"
                    width: sideInfos.infoWidth; height: parent.height
                    anchors{left: signText.right; leftMargin: sideInfos.widthSpacing}
                    Text{
                        id: infoText; anchors.fill: parent; color: "#971515"
                        text: " "+ sideInfos.infos[index]
                        font.pixelSize: fontTooBig; fontSizeMode: Text.Fit
                        horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
                    }
                }
            }

        }
    }

    Card{ id: questionBlock
        signal questionClicked()        
        anchors.horizontalCenter: parent.horizontalCenter
        width: cardWidth*questionBlockScale; height: cardHeight*questionBlockScale
        fgTextHozAlignment: questionType == Value.questionWordsID? Text.AlignHCenter : Text.AlignLeft
        fgTextPixelSize: theFontSize
        bgTextHozAlignment: questionType == Value.questionWordsID? Text.AlignLeft : Text.AlignHCenter
        bgTextPixelSize: theFontSize
        y:80*vRatio
        flipDuration: flipTime
        bgFrameUrl: "qrc:/pic/cardfront2.png"
        fgImageUrl: "qrc:/pic/cardback1.png"
        fgShowType: showImage
        mouse.onClicked: questionClicked()
    }


    AutoImage{
        id: timeBar_BG
        autoCalculateSize: false;
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 62*vRatio
        anchors{top: questionBlock.bottom; topMargin: 20*vRatio}
        source:"qrc:/pic/directMatchGame_ Time running bar.png"
    }

    Rectangle{
        id: timeCountingRedBar; color: "#912a49"
        property real life: 1
        anchors{left: timeBar_BG.left; leftMargin:33*hRatio; top: timeBar_BG.top; topMargin: 12.3*vRatio}
        width: isViewWidthShorter? 687*hRatio*life :687*hRatio*(1-gridPercentage)*life
        height: 36*vRatio
        radius: 10*hRatio

        transformOrigin: Item.TopLeft
    }

    AutoImage{
        id:choiceButtonGrid_BG
        autoCalculateSize: false;
        anchors.top: timeBar_BG.bottom
        width: parent.width; height: parent.height-y
        source:"qrc:/pic/directMatchGame_ BG color layer_Dark Green area.png"


        Grid{//ChoiceButtons （Displayed in grid)
            id: choiceButtonGrid
            property int buttonSize: getButtonSize(rows,columns, width, height)
            property real minSpacing: 10*vRatio

            function getButtonSize(rows, columns, gridWidth, gridHeight) {
                var maxHeightSize, maxWidthSize
                    maxWidthSize = (gridWidth * (1-Settings.spacingPercentage))/columns
                    maxHeightSize = (gridHeight * (1-Settings.spacingPercentage))/rows
                    return Math.min(maxWidthSize,maxHeightSize)
            }
            rows: isViewWidthShorter? largerSide: smallerSide
            columns: isViewWidthShorter? smallerSide: largerSide

            width: parent.width - 2*x; height: parent.height - 2*y
            x: 80*hRatio; y: 20*vRatio
            rowSpacing: (parent.height-rows*buttonSize-2*y)/(rows-1);
            columnSpacing: (parent.width-columns*buttonSize-2*x)/(columns-1)


            Repeater {
                id: choiceButtons
                model: numOfChoices
                signal choiceButtonClickedAt(int index)

                Card {
                    id: eachButton

                    width: choiceButtonGrid.buttonSize; height: width
                    mouse.onPressed: {scaleAnimation.start() }
                    mouse.onClicked: {choiceButtons.choiceButtonClickedAt(index)}
                    fgTextHozAlignment: answerType == Value.answerWordsID? Text.AlignHCenter : Text.AlignLeft
                    fgTextPixelSize: theFontSize
                    bgTextHozAlignment: answerType == Value.answerWordsID? Text.AlignLeft : Text.AlignHCenter
                    bgTextPixelSize: theFontSize
                    flipDuration: flipTime
                    fgShowType: showImage
                    fgImageUrl: "qrc:/pic/cardback1.png"
                    bgFrameUrl: "qrc:/pic/cardfront2.png"

    //                MouseArea {
    //                    Cannot implement another mouseArea here. The propagation mechanisim is
    //                    not well designed. If there is only one mouse event (no matter it is
    //                    composed event or not), it can work fine. If you have two mouse event,
    //                    There is no way to "execute and propagate" two mouse event to lower layer.
    //                    Use signal instead.
    //                }
                }
            }
        }
    }

    Rectangle{ id: halfCorrectLeftHint;
        opacity: 0.5; visible: false
        width: choiceButtonGrid.buttonSize; height: choiceButtonGrid.buttonSize
        Text{ id: txthalfCorrectLeftHint
            anchors.fill: parent
            font.pixelSize: fontTooBig
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{ anchors.fill: parent }
    }
    Rectangle{ id: halfCorrectRightHint;
        opacity: 0.5; visible: false
        width: choiceButtonGrid.buttonSize; height: choiceButtonGrid.buttonSize
        Text{ id: txthalfCorrectRightHint
            anchors.fill: parent
            font.pixelSize: fontTooBig
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea{ anchors.fill: parent }
    }
}
