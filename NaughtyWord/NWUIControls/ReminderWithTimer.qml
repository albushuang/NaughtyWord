import QtQuick 2.0
import "qrc:/../../UIControls"

//Rectangle{ id: root
Item { id: root
    //source: "qrc:/pic/decksView_white area.png"
    visible: false;  clip: false
    width: 250*hRatio
    height: reminderText.height*1.2
    opacity: 1
    property real reminderDuration: 3000
    property string textContent: ""
    property int fontSize: 16
    property variant enumDirection: moveAnim.enumDirection
    property bool remindCancelOption: true
    property string reminderType: ""
    property var cycleEndCallback
    signal noRemindClicked(string type)

    MouseArea{ id: mouseStealer; anchors.fill: parent }

    MoveAnimation{id: moveAnim
        target: root
        onAllStopped: {
            if(visible==false && typeof(cycleEndCallback)!="undefined") { cycleEndCallback(); }
        }
    }

    Image { id: mainBG
        source : "qrc:/cloud.png"
        width: parent.width; height: width*sourceSize.height/sourceSize.width
        Text { id: reminderText; color: "black"
            width: 200*parent.width/315; height: 120*parent.height/232;
            //width: parent.width*0.5; height: text == "" ? 0 : contentHeight  //It'd better to assign height instead of undefined
            //anchors.centerIn: parent
            x: parent.width/2-contentWidth/2; y: parent.height/2-contentHeight/2
            font.pointSize: fontSize; wrapMode: Text.WordWrap; //fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignLeft;
            //verticalAlignment: Text.AlignVCenter;
            fontSizeMode: Text.Fit
            text: textContent
        }
    }



    function showReminder(text, direction){
        textContent = text;
        moveAnim.direction = direction;
        root.visible = true
        moveAnim.show()
        durationTimer.start()
    }

    function end(){
        durationTimer.stop();
        moveAnim.end()
    }

    Timer{ id: durationTimer
        interval: reminderDuration
        repeat: true
        onTriggered:{ end() }
    }
    AutoImage{
        source: "qrc:/pic/decksView_white area.png"
        width: mainBG.width //noRemind.contentWidth*1.2
        height: { noRemind.contentHeight*1.05 > mainBG.height/3 ? noRemind.contentHeight*1.05: mainBG.height/3 }
        opacity: 0.5
        visible: remindCancelOption
        anchors { top: mainBG.bottom; topMargin: 5*vRatio
            horizontalCenter: parent.horizontalCenter
        }
        Text { id: noRemind; color: "black"
            width: parent.width*0.95; height: mainBG.height/3 //text == "" ? 0 : contentHeight  //It'd better to assign height instead of undefined
            //anchors.centerIn: parent
            x: parent.width/2-contentWidth/2; y: parent.height/2-contentHeight/2
            font.pointSize: fontSize-2; wrapMode: Text.WordWrap;
            horizontalAlignment: Text.AlignLeft;
            //verticalAlignment: Text.AlignVCenter
            fontSizeMode: Text.Fit
            text: qsTr("Hide this next time.")
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{
                noRemindClicked(reminderType)
                end();
            }
        }
    }
}



