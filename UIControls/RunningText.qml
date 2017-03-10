import QtQuick 2.0

Text {id: root
/* Start of public members*/
    property real maxFontSize   //[Mandatory]
    property int wordInterval: 66 //[Optional] default = 66 msec will show next word
    signal runningTextClickAgain()

    function start(){
        own.fullText = text
        font.pixelSize = maxFontSize

/* Do Text.Fit menually. So we can get actual pixelSize when full text is displayed*/
        while(contentWidth > width || contentHeight>height){
            font.pixelSize -= 1
        }

//        console.log("font pixel", font.pixelSize)
//        console.log("contentWidth", contentWidth)
//        console.log("contentHeight", contentHeight)

        root.text = " "
        runningTimer.count = 0
        runningTimer.restart()
    }
/* End of public members*/


/* Cannot find a good way to do it right when alignment is center.*/
//    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
/* Need to do Text.Fit menually*/
//    fontSizeMode: Text.Fit;
    wrapMode: Text.WordWrap

    Timer{id: runningTimer; interval: wordInterval; repeat:true; triggeredOnStart: true
        property int count
        onTriggered: {
            if(count <= own.fullText.length){
                root.text = own.fullText.substr(0, count)
//                var numOfSpaceNeeded = Math.round(
//                            (own.contentWidth*(own.contentHeight/own.oneSpeceHeight - root.contentHeight/own.oneSpeceHeight)
//                             + own.contentWidth - root.contentWidth)/own.oneSpeceWidth)
//                root.text += (new Array(numOfSpaceNeeded + 1)).join(" ")
//                console.log("numOfSpaceNeeded", numOfSpaceNeeded)
                count++
            }else{
                stop()
            }
        }
    }
    MouseArea{id: tap; anchors.fill: parent
        onClicked: {
            if(root.text == own.fullText){
                runningTextClickAgain();
            }else{
                runningTimer.stop()
                root.text = own.fullText
            }
        }
    }

    QtObject{id: own
        property string fullText
    }
}

