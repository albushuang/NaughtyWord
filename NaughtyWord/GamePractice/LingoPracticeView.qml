import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Particles 2.0
import "ViewSettingsInLingoPractice.js" as Settings
import "qrc:/../../UIControls"


Rectangle{
    width: parent.width; height: parent.height
    property int numberOfChoice
    property int newsLen
    property int learnsLen
    property int reviewsLen
    property alias questionBlock: questionBlock
    property alias questionImageArea: questionImageArea
    property alias choiceButtons: choiceButtons
    property alias answerGesture: answerGesture
    property alias gestureArrowHint: gestureArrowHint
    property alias wordArea: wordArea
    property alias phonicAlphabetArea: phonicAlphabetArea

    AutoImage{id: background; anchors.fill: parent
        source: "qrc:/pic/background0.png"
    }
    AutoImage{id: topBackground
        y: 18*vRatio; source: "qrc:/pic/Practice_top image.png"
    }
    AutoImage{id: remainsBar; width:parent.width
        y: 209*vRatio; source: "qrc:/pic/Practice_Remain Blue bar.png"
    }
    Row{
        anchors.centerIn: remainsBar
        width: {
            var tempWidth = 0
            for(var i=0; i< txtArr.count; i++) {tempWidth +=  txtArr.itemAt(i).width }
            tempWidth
        }
        height: 31*vRatio
        Repeater{id: txtArr
            model: 4
            property variant displayStr: [qsTr("Today's schedule remains:   "), qsTr("New = %1,  ").arg(newsLen.toString()),
            qsTr("Learning = %1,  ").arg(learnsLen.toString()),
            //: Show users how many words are still to be reviewed
            qsTr("Review = %1").arg(reviewsLen.toString())]
            Text{id: remainsText; color:"#e8cc5f"
                width: contentWidth; height: parent.height
                text: txtArr.displayStr[index]
                font.pointSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
            }
        }
    }

    Item{
        id: questionBlock
        width: parent.width - Settings.questionLeftMargin*2
        height: parent.height - Settings.choiceHeight - Settings.questionBottomMargin - Settings.questionTopMargin
        x: Settings.questionLeftMargin
        y: Settings.questionTopMargin

        property string word
        property string phonicAlphabet
        property string imageUrl
        property string translation
        property string speechFile

        Rectangle{id: line1; width: parent.width; height:4*vRatio; color:"#336699"
        }

        Item{id: wordArea
            width: parent.width; height: 83*vRatio
            anchors{top: line1.bottom; topMargin: 9*vRatio}
            Rectangle{id: wordBackground; anchors.fill: parent; opacity: 0.5; radius: 14*hRatio; }
            Text {
                id: wordText; color: line1.color
                width: parent.width; height: 50*vRatio
                anchors.centerIn: parent
                text: questionBlock.word
                font.bold: true; font.pointSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle{id: line2; width: parent.width; height:line1.height; color: line1.color
            anchors{top: wordArea.bottom; topMargin: wordArea.anchors.topMargin}
        }
        Item{
            id: phonicAlphabetArea
            signal speechClicked()
            width: parent.width; height: 38*vRatio
            anchors { horizontalCenter: parent.horizontalCenter; top: line2.bottom; topMargin: 11*vRatio}
            z: 1

            Text{
                id: paText; color: line1.color
                width: Math.min(contentWidth, 585*hRatio); height: parent.height
                anchors.centerIn: parent
                text: {
                    var temp = questionBlock.phonicAlphabet.split("\n")[0]  //Remove \n
                    while(temp.substr(-1,1) == " "){temp = temp.substr(0, temp.length-1)} //Remove space
                    temp
                }
                font.bold: false; font.pixelSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                MouseArea {
                    anchors.fill: parent; z:1
                    onClicked: phonicAlphabetArea.speechClicked()
                }
            }
            AutoImage {id: speaker
                source : "qrc:/pic/Practice_speaker.png"
                anchors { left: parent.left;rightMargin: 20*hRatio; top: paText.top }
                width: height; height: paText.height
                visible: questionBlock.speechFile != ""
                MouseArea {
                    anchors.fill: parent; z:1
                    onClicked: phonicAlphabetArea.speechClicked()
                }
            }

        }
        Rectangle {
            id: questionImageArea
            width: parent.width; height: 516*vRatio
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: phonicAlphabetArea.bottom; topMargin: 18*vRatio
            }
            border{width: line1.height; color: line1.color}
            color: "transparent"
            Rectangle{id: blueBackground; anchors.centerIn: parent
                color: "#336699"; opacity: 0.5
                width: 651*hRatio; height: 485*vRatio
            }
            Image{
                source: questionBlock.imageUrl
                anchors.fill: blueBackground
                fillMode:{
                    if(sourceSize.width > width || sourceSize.height > height){
                        Image.PreserveAspectFit
                    }else{
                        Image.Pad
                    }
                }
            }
        }
        Item{id: translateBackground; z: 1
            width: 683*hRatio; height: 299*vRatio - choiceBackground.height
            anchors {
                horizontalCenter: parent.horizontalCenter; top: questionImageArea.bottom; topMargin: 16*vRatio
            }
            Rectangle{anchors.fill: parent; opacity: 0.5}
            Flickable{
                id: transFlickable
                anchors.fill: parent
                interactive: translation.contentHeight > height
                contentHeight: translation.contentHeight > height ? translation.contentHeight : -1
                clip: true;


                Text{
                    id: translation
                    width: parent.width - flickBall.width-20
                    height: parent.height
                    text: questionBlock.translation
                    wrapMode: Text.Wrap
                    font.pixelSize: pFontSize
                    font.bold: false; fontSizeMode: Text.FixedSize
                    horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
                    anchors {horizontalCenter: parent.horizontalCenter}
                }
            }
            Rectangle{id: flickBar; color: line1.color
                x: 655*hRatio; y: 11*vRatio
                width:6*hRatio; height: translateBackground.height - 30*vRatio
                visible: transFlickable.visibleArea.heightRatio != 1
                AutoImage{id: flickBall
                    source: "qrc:/pic/Practice_move dot.png"
                    anchors.horizontalCenter: flickBar.horizontalCenter
                    y: transFlickable.visibleArea.yPosition/
                       (1.0 - transFlickable.visibleArea.heightRatio) * (flickBar.height + 2*vRatio - height)
                }
            }
        }


        Item{
            id: gestureArrowHint; z:2
            property alias arrows: arrows
            property point pressedPoint: mapFromItem(answerGesture,
                                         answerGesture.pressedPoint.x, answerGesture.pressedPoint.y)
            opacity: 0; visible:false
            Behavior on opacity{PropertyAnimation{duration: 600 }}
            AutoImage{id: arrowCenter
                source: "qrc:/pic/Practice_center.png"
                width: 77*hRatio; height: 55*vRatio
                x: gestureArrowHint.pressedPoint.x - width/2; y: gestureArrowHint.pressedPoint.y - height/2
                Behavior on opacity{PropertyAnimation{duration: 800 }}
            }

            Repeater{id: arrows
                model: numberOfChoice
                ArrowSign{                    
                    pressedPoint: gestureArrowHint.pressedPoint
                    textContent: choiceButtons.itemAt(index).textContent
                }
            }
        }



        MouseArea{
            id: answerGesture
            signal swiped(string direction)
            signal tapped()
            property point pressedPoint
            anchors.fill: parent
            preventStealing: true
            z: 0
            onPressed:{
                pressedPoint = Qt.point(mouse.x, mouse.y)
                if(gestureArrowHint.visible){
                    gestureArrowHint.opacity = 1
                }
            }

            onReleased:{
                var diffX = mouse.x - pressedPoint.x
                var diffY = mouse.y - pressedPoint.y
                if(Math.abs(diffX) >= Math.abs(diffY)){
                    if(diffX > Settings.swipeValidDistance){
                        swiped("right")
                    }else if(diffX < -Settings.swipeValidDistance){
                        swiped("left")
                    }else{
                        tapped()
                    }
                }else{
                    if(diffY >  Settings.swipeValidDistance){
                        swiped("down")
                    }else if(diffY < -Settings.swipeValidDistance){
                        swiped("up")
                    }else{
                        tapped()
                    }
                }

                gestureArrowHint.opacity = 0

            }

        }

    }

    Rectangle{
        id: choiceBackground
        width: parent.width; height: Settings.choiceHeight
        x: 0; y: parent.height - height
        color: "grey"
    }

    Row{//ChoiceButtons （Displayed in row)
        width: Settings.choiceWidth * numberOfChoice + (numberOfChoice - 1) * 10
        height: Settings.choiceHeight*2/3
        anchors.centerIn: choiceBackground
        spacing: Settings.choiceSpacing

        Repeater {
            id: choiceButtons
            model: numberOfChoice
            property int focusIndex
            signal choiceButtonClickedAt(int index)

            Rectangle {
                id: eachButton
                width: Settings.choiceWidth; height: Settings.choiceHeight*2/3
                property string textContent
                property int easiness
                property bool withBorder: false
                radius: 5
                border.width: (choiceButtons.focusIndex == index ) ? 3 : 0
                border.color: "#666699"
                Text {
                    width: Math.max(parent.width - border.width*2, 0)
                    height: Math.max(parent.height - border.width*2, 0)
                    anchors.centerIn: parent
                    text: textContent
                    font.pointSize: 20
                    font.bold: true
                    fontSizeMode: Text.Fit
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: height != 0
                }
                MouseArea {
                    anchors.fill: parent; z:1
                    onClicked:{
                        choiceButtons.choiceButtonClickedAt(easiness)
                    }
                }
            }
        }
    }

}

