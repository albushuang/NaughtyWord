import QtQuick 2.0
import Box2D 2.0
import "qrc:/../UIControls"

Item{id: root
    property alias source: choiceImage.source
    property alias letter: spellingText.text
    property alias choiceBox:choiceBox
    property real hRatio: width/148
    property real vRatio: hRatio
    property bool isImageMode
    height: isImageMode ? width*176/148 : width

    function startHint(){
        hintAnimation.running = true;
    }
    function stopHint(){
        hintAnimation.running = false;
        imageFrame.opacity = spellingFrame.opacity = 1
    }

    AutoImage{id: spellingFrame; visible: !isImageMode && letter != ""
        anchors.fill: parent; autoCalculateSize: false
        source: "qrc:/pic/insanity_Star.png"
    }

    Text{id: spellingText; visible: !isImageMode; color: "#ffcc66"
        x: 23*hRatio; y: 23*vRatio
        width: parent.width*0.65; height: parent.height*0.65
        font.pointSize: 100; fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }


    AutoImage{
        id: imageFrame
        x: 0; y:0
        width: parent.width; height: parent.height
        source: "qrc:/pic/insanity_photo frame (yellow).png"
        visible: isImageMode && choiceImage.source != "" && choiceImage.status == Image.Ready
    }

    Image {
        id: choiceImage
        width: 129*hRatio; height: 129*vRatio
        x: 10.5*hRatio
        anchors{/*horizontalCenter: parent.horizontalCenter; */bottom: parent.bottom; bottomMargin: 8.5*vRatio }
        fillMode:  Image.Stretch //Image.PreserveAspectCrop//PreserveAspectFit
        asynchronous: true
    }

    SequentialAnimation{
        id: hintAnimation
        running: false;
        loops: Animation.Infinite
        NumberAnimation{target: isImageMode? imageFrame: spellingFrame;
            properties: "opacity"; to: 0.1; duration: 800}
        NumberAnimation{target: isImageMode? imageFrame: spellingFrame;
            properties: "opacity"; to: 1; duration: 800}
    }


    Body{
        id: choiceBody
        target: root  //I don't know why I cannot make target as imageFrame
        world: physicsWorld
        bodyType: Body.Dynamic
        sleepingAllowed: false
        fixedRotation: true
        fixtures: Box {
            id: choiceBox
            property variant parent: root
            //If (isImageMode), then make choiceBox be the golden ball
            x: isImageMode? 52*hRatio: 0;
            y: isImageMode? 14*vRatio: 0
            width: isImageMode? 45*hRatio: root.width;
            height: isImageMode? 20*vRatio: root.height
            density: 1
            friction: 0
            restitution: 0
            categories: Box.Category3
            collidesWith: Box.Category2
            onBeginContact: {
                collideChoice(index);

            }
        }
    }
}
