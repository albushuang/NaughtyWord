import QtQuick 2.5
import QtQuick.Particles 2.0

Flipable {id: root

//Adjust all display parameters here
    property int borderSize: 3
    property int flipDuration: 500

//In order to make this item easy to use, try not to open (alias) the whole item
//    property alias fgText: fgText
//    property alias fgImage: fgImage
//    property alias bgText: bgText
//    property alias bgImage: bgImage
    property alias mouse: mouse
    property alias rotationAnimation: rotationAnimation //Assign rotation angle and duration directly
    property alias scaleAnimation: scaleAnimation
    property alias rotation: rotation
    property real rotateOriginX: root.width/2
    property real rotateOriginY: root.height/2
    property real rotationAngle: 180

    property string fgImageUrl
    property string fgFrameUrl
    property string bgFrameUrl
    property string fgTextContent
    property var fgTextHozAlignment: Text.AlignHCenter
    property string bgImageUrl
    property string bgTextContent
    property var bgTextHozAlignment: Text.AlignHCenter
//    property enumeration showText: 0   //Cannot create enum without C++
    property string fgShowType: showBoth
    property string bgShowType: showImage

    property real fgTextPixelSize:66  //Assign different text font size if necessary
    property real bgTextPixelSize:66  //Assign different text font size if necessary
    property bool flipped: false    //If flipped == true, show background

    readonly property string showText: "TextOnly"
    readonly property string showImage: "ImageOnly"
    readonly property string showBoth: "Both"

    function resetBlock(resetState){
        state = resetState == "none" ? state : resetState
        fgTextContent = ""
        fgImageUrl = ""
        bgTextContent = ""
        flipped = false
        enabled = true
        mouseSparkler.enabled = false
    }

    function disableCard(color){
        disableFog.color = color
        root.enabled = false
        disableFog.visible = true
    }

    function enableCard(){
        root.enabled = true
        disableFog.visible = false
    }
    Rectangle{id: disableFog; anchors.fill: parent; color: "gray"; opacity: 0.25; visible: false}

    front: Item{anchors.fill: parent
        Image {id: fgImage; visible: fgShowType != showText
            anchors { left:parent.left; right:parent.right; bottom:parent.bottom; margins:8; top: parent.top; topMargin:9}
            source: fgImageUrl
            fillMode:  Image.Stretch
            asynchronous: true
            clip: true
            //mipmap: true
        }

        Rectangle {
            anchors {left:parent.left;right:parent.right;bottom:parent.bottom;margins:8; top: parent.top;topMargin:9; }
            radius: 5; color: "white"
            visible: fgShowType != showImage
            anchors.fill: parent
            Text { id: fgText;
                anchors {top: parent.top;left:parent.left;right:parent.right;bottom:parent.bottom;margins:6}
                text: fgTextContent
                font.pixelSize: fgTextPixelSize; font.bold: true; fontSizeMode: Text.Fit; wrapMode: Text.WordWrap
                horizontalAlignment: fgTextHozAlignment
//                lineHeight: 0.8
                /*|| contentHeight == 0 || height < 0 is to solve weird binding loop problem*/
                verticalAlignment: (contentHeight < height || contentHeight == 0 || height < 0) ?
                                       Text.AlignVCenter : Text.AlignTop
                minimumPixelSize: 5
                clip: true
            }
        }
        AutoImage {
            anchors.fill: parent
            source: fgFrameUrl
//            sourceSize.width: width; sourceSize.height: height
        }
    }

    back: Item {anchors.fill: parent
        AutoImage { id: bgImage; visible: bgShowType != showText
            source: bgImageUrl; anchors.fill: parent; clip: true;
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
//            sourceSize.width: width; sourceSize.height: height
        }
        Rectangle {
            anchors {left:parent.left;right:parent.right;bottom:parent.bottom;margins:8; top: parent.top;topMargin:9; }
            radius: 5; color: "white"
            visible: bgShowType != showImage
            anchors.fill: parent
            Text { id: bgText; visible: bgShowType != showImage
                anchors {top: parent.top;left:parent.left;right:parent.right;bottom:parent.bottom;margins:6}
                text: bgTextContent
                font.pixelSize: bgTextPixelSize; font.bold: true; fontSizeMode: Text.Fit; wrapMode: Text.WordWrap
                horizontalAlignment: bgTextHozAlignment
//                lineHeight: 0.8
                /*|| contentHeight == 0 || height < 0 is to solve weird binding loop problem*/
                verticalAlignment: (contentHeight < height || contentHeight == 0 || height < 0)
                                   ? Text.AlignVCenter : Text.AlignTop
                minimumPixelSize: 5
                clip: true
            }
        }
        AutoImage {
            anchors.fill: parent
            source: bgFrameUrl
//            sourceSize.width: width; sourceSize.height: height
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onReleased: {
            sparkleTimer.start()
        }

        onPressed: {
            mouseSparkler.enabled = true
        }
    }
    ParticleSystem {
        anchors.fill: parent
        ImageParticle {
            anchors.fill: parent
            source: "qrc:///particleresources/star.png"
            color:"#FF1010"
            redVariation: 0.8
        }

        Emitter {
            id: mouseSparkler
            emitRate: 80
            lifeSpan: 600
            size: 32; sizeVariation: 8
            velocity: PointDirection{ x: 0; xVariation: 70; y: 0; yVariation: 70 }
            width: 0; height: 0
            x: mouse.mouseX; y: mouse.mouseY
            enabled: false
        }
    }

    Timer{
        id: sparkleTimer
        interval: 200
        onTriggered: {
            mouseSparkler.enabled = false
        }
    }
// For flip funcion
    transform: Rotation {
        id: rotation
        origin.x: rotateOriginX
        origin.y: rotateOriginY
        axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
        angle: 0    // the default angle
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: rotationAngle }
        when: root.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: flipDuration }
    }

// For rotation function. (NOTE!! Rotation is different from flip)
    PropertyAnimation {
        id: rotationAnimation
        target: root
        properties: "rotation"
        from: 0; to: 360
        duration: 1000
    }

//  For button effect
    SequentialAnimation on scale{
        id: scaleAnimation
        running: false
        NumberAnimation{from: 1; to: 1.15; duration: 100}
        NumberAnimation{from: 1.15; to: 1; duration: 70}
    }
}

