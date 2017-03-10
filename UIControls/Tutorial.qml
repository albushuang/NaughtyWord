import QtQuick 2.0

Item {id: root
    anchors.fill: parent
/* -----Public members (properties or functions)----- */
    property int tutorialKey //[Mandaory]
    property var tutScript //[Mandaory]
    property QtObject focusItem //[Option]  focusItem should be tutorial's sibling or its sibling's children
    property QtObject focusBtn //[Option]  tool buttons are children of application. So it should be handled separately
    // If autoPositioning is true, guide image and guide text will be located automatically,
    // otherwise, the user have to assign the (x,y) and (width,height) of gImage and gText outside
    property bool imgAutoPositioning: true //[Option]
    property bool txtAutoPositioning: true //[Option]
    property bool foggyEffect: true //[Option]
    property alias gImage: gImage //[Option] g = guide
    property real imageRatio: 0.7   //[Option] the width & height cannot be over than imageRatio of parent's width&height
    property alias gText: gText //[Option]
    property alias textBorderFrame: textBorderFrame
    property int spacing: 15 //[Option] the distance between gImage and gText
    property bool focusFrameEnabled: true //[Option]    //A red frame on focusItem
    property Image indicator
    signal foggyAreaClicked()
    signal runningTextClickAgain()
    /*The purpose of delay is that user can see this page for a while.
    Or sometimes, parent's width and heigth are not ready*/
    function start(delayTime){
        onGoing = true
//        delayTime = delayTime || 0;  //(Set default value 0 to delayTime if it is "undefined")
        if(typeof(delayTime) != "undefined"){
            delayTimer.interval = delayTime
            delayTimer.start()
        }else{
            delayTimer.triggered()
        }
    }

    function stop(){
        visible = false
        onGoing = false
        resetTutorial()

    }

    function isOnGoing(key){
        return onGoing && tutorialKey == key
    }

/* -----Private members (properties or functions)----- */
    property variant goodArea
    property bool onGoing: onGoing
    property bool hasFocusItem: focusItem != null
    property bool hasFocusBtn: focusBtn != null
    visible: false

    Timer{id: delayTimer
        onTriggered: {
            visible = true
            if(hasFocusItem){
                hollowBlock.initHollowBlock();
            }
            if(imgAutoPositioning || txtAutoPositioning){
                calculateGoodArea()
            }

            gImage.initImage()  //Please initImage first, and then initText
            gText.initText()
            gText.start()
            if(indicator!=null) {
                if (focusFrame.visible || focusBtnFrame.visible) {
                    indicatingx.stop()
                    indicatingy.stop()
                    own.getIndicatorPosition()
                    indicatingx.start()
                    indicatingy.start()
                } else { indicator.visible = false}
            }
        }
    }

    QtObject { id: own
        function getIndicatorPosition() {
            indicator.x = (gImage.x+hollowBlock.x)/2
            indicator.y = (gImage.y+gImage.height/3+hollowBlock.y)/2
            indicatingx.from = indicator.x
            indicatingy.from = indicator.y
            indicatingx.to = hollowBlock.x+hollowBlock.width/2
            indicatingy.to = hollowBlock.y+hollowBlock.height/2
            indicator.visible = true
        }
    }

    NumberAnimation { id: indicatingx
        alwaysRunToEnd: false
        target: indicator
        property: "x"
        duration: 2200
        easing.type: Easing.OutExpo
        onStopped: { if(!root.visible) return; own.getIndicatorPosition(); start() }
    }
    NumberAnimation { id: indicatingy
        alwaysRunToEnd: false
        target: indicator
        property: "y"
        duration: 2200
        easing.type: Easing.OutExpo
        onStopped: { if(!root.visible) return; own.getIndicatorPosition(); start() }
    }

    MouseArea{id: mouseStealerDuringDelay
        parent: root.parent //Need to make this MouseArea's parent to tutorial's parent
        anchors.fill: root; enabled: delayTimer.running
        onClicked: {console.log("mouse stealer is clicked")}
    }

    Item{id: hollowBlock; x:0; y:0; width: 0; height: 0;
        function initHollowBlock() {
            width = focusItem.width; height = focusItem.height;
            var refPoint = root.mapFromItem(focusItem.parent, focusItem.x, focusItem.y)
            x = refPoint.x; y = refPoint.y
        }
    }

    Rectangle{id: focusFrame; z:1; visible: focusFrameEnabled && hasFocusItem
        property int spacing: border.width + 5
        x: hollowBlock.x - spacing; y: hollowBlock.y - spacing;
        width: hollowBlock.width + spacing*2; height: hollowBlock.height + spacing*2
        border{width:3; color: "red" } color: "transparent";
        radius: 10
    }

    Rectangle{id: focusBtnFrame; z:1; visible: focusFrameEnabled && hasFocusBtn
        parent: hasFocusBtn? focusBtn : root
        property int spacing: border.width
        x: 0 - spacing ; y: 0 - spacing;
        width: hasFocusBtn ? (focusBtn.width + spacing*2) : 0; height: hasFocusBtn? (focusBtn.height + spacing*2):0
        border{width:1; color: "red" } color: "transparent";
        radius: 10
    }

    Repeater{ id: foggyBackgound

        anchors.fill: parent; z: 0;
        model: 4 // Currently, I can only come up with the solution of 1 focus window

        Rectangle{visible: foggyEffect
            color: "white"; opacity: 0.6
            //Clark: Need another document (drawing) to explain the following code. Too hard to explain by words
            x: index == 2 ? hollowBlock.x + hollowBlock.width : 0;
            y: {
                switch(index){
                case 0: 0; break;
                case 1: hollowBlock.y; break;
                case 2: hollowBlock.y; break;
                case 3: hollowBlock.y + hollowBlock.height; break;
                }
            }
            width:{
                switch(index){
                case 0: parent.width; break;
                case 1: hollowBlock.x; break;
                case 2: parent.width - hollowBlock.x - hollowBlock.width; break;
                case 3: parent.width; break;
                }
            }
            height: {
                switch(index){
                case 0: hollowBlock.y; break;
                case 1: hollowBlock.height; break;
                case 2: hollowBlock.height; break;
                case 3: parent.height - hollowBlock.y - hollowBlock.height; break;
                }
            }
            MouseArea{
                anchors.fill: parent;
                onClicked:{
                    mouse.accepted = true; foggyAreaClicked()
                }
            }

//            anchors{  //We cannot anchor to a item which is not a sibling or parent
//                left: index == 2 ? focusItem.right : parent.left;
//                right: index == 1 ? focusItem.left : parent.right;
//                top: index == 1 || index == 2 ? focusItem.top : (index == 0 ? parent.top : focusItem.bottom);
//                bottom: index == 1 || index == 2 ? focusItem.bottom : (index == 0 ? focusItem.top : parent.bottom);
//            }
        }
    }

    AutoImage{id: gImage; z:2

//        onXChanged: {console.log("img x:", x)}
//        onYChanged: {console.log("img y:", y)}
//        onWidthChanged: {console.log("img width:", width)}
//        onHeightChanged: {console.log("img height:", height)}

        function initImage(){
            // buggy in tutorial mode
            source = tutScript.getScriptObj(tutorialKey).imageSource
            if(imgAutoPositioning){
                assignImageSize()   //please assign size before position
                assignImagePosition()
            }
        }
        function assignImageSize(){            
            width = sourceSize.width; height = sourceSize.height;
            if(width == 0 || height == 0){
                width = root.width; height = 0;
            }

//            console.log("image width:" + width + " height:" + height)
            switch(goodArea.areaDirection){
            case "left":
            case "right":                
                if(width > goodArea.distanceToBorder * imageRatio){
                    var oldWidth = width
                    width = goodArea.distanceToBorder * imageRatio
                    height = height * width / oldWidth
                }
                if( height > root.height * imageRatio){
                    var oldHeight = height
                    height = root.height * imageRatio
                    width = width * height / oldHeight
                }                
                break;
            case "up":
            case "down":
//                console.log("root width:" + root.width + " height:" + root.height)
//                console.log("image width:" + width + " height:" + height)
                if( height > goodArea.distanceToBorder * imageRatio){
                    oldHeight = height                    
                    height = goodArea.distanceToBorder * imageRatio
                    width = width * height / oldHeight
                }
//                console.log("image width:" + width + " height:" + height)
                if(width > root.width * imageRatio){
                    oldWidth = width
                    width = root.width * imageRatio
                    height = height * width / oldWidth
                }
                break;
            }
//            console.log("image width:" + width + " height:" + height)
        }
        function assignImagePosition(){
            var centerPositionRatio = 0.5
            switch(goodArea.areaDirection){
            case "left":
                x = goodArea.distanceToBorder/2 - width/2
                y = root.height*centerPositionRatio - height/2
                break;
            case "up":
                x = root.width/2 - width/2
                y = goodArea.distanceToBorder*centerPositionRatio - height/2
                break;
            case "right":
                x = (root.width - goodArea.distanceToBorder/2) - width/2
                y = root.height*centerPositionRatio - height/2
                break;
            case "down":
                x = root.width/2 - width/2
                y = (root.height - goodArea.distanceToBorder*(1-centerPositionRatio)) - height/2
            }

        }
    }

    RunningText{id: gText; z:1
        maxFontSize: mFontSize*2; /*fontSizeMode: Text.Fit;*/ wrapMode: Text.WordWrap
//        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        color: "#4D4D4D" /*dark gray*/
//        onXChanged: {console.log("txt x:", x)}
//        onYChanged: {console.log("txt y:", y, "\n")}
//        onWidthChanged: {console.log("text width:", width)}
//        onHeightChanged: {console.log("text height:", height)}
        onRunningTextClickAgain: root.runningTextClickAgain()
        function initText(){
            text = tutScript.getScriptObj(tutorialKey).guideText
            if(txtAutoPositioning){
                assignTextSize()   //please assign size before position
                assignTextPosition()
            }
        }
        function assignTextSize(){
            switch(goodArea.areaDirection){
            case "left":
            case "right":
                width = gImage.width
                height = (root.height - gImage.y - gImage.height)/2
                break;
            case "up":
                width = gImage.width
                height = (focusFrame.y - gImage.y - gImage.height)/2
                break;
            case "down":
                width = gImage.width
                height = (root.height - gImage.y - gImage.height)/2
//                console.log("height:" + height)
                break;

//            case "up":    //This code is to put text to right part of image
//            case "down":  //But it seems better to always put text beneath image
//                width = (root.width - gImage.x - gImage.width ) * 0.7
//                height = gImage.height/2
//                break;
            }
        }
        function assignTextPosition(){
            switch(goodArea.areaDirection){
            case "left":
            case "right":
            case "up":
            case "down":
                x = gImage.x
                y = gImage.y + gImage.height + spacing
                break;
//            case "up":    //This code is to put text to right part of image
//            case "down":  //But it seems better to always put text beneath image
//                x = gImage.x + gImage.width + 30
//                y = gImage.y + gImage.height/2 - height/2
//                break;
            }
        }
    }

    Rectangle{id: textBorderFrame
        property int spacing: border.width + 5
        x: gText.x - spacing; y: gText.y - spacing
        width: gText.width + spacing*2; height: gText.height + spacing*2
        border{width:5; color: "#4D4D4D" /*dark gray*/} color: "white";
        radius: 10
    }

    function calculateGoodArea(){   //a good area is the area large enough for image and text
        var useSpaceOf = "left", maxDistance = hollowBlock.x
//        console.log("application width:" + application.width + " height:" + application.height)
//        console.log("parent width:" +parent.width + " height:" + parent.height)
//        console.log("root width:" +root.width + " height:" + root.height)
        if(root.width <= 0 || root.height <= 0){
            root.width = application.width;
            root.height = application.height;
        }

        if(maxDistance < hollowBlock.y){
            maxDistance = hollowBlock.y
            useSpaceOf = "up"
        }
        if( maxDistance < root.width - hollowBlock.x - hollowBlock.width){
            maxDistance = root.width - hollowBlock.x - hollowBlock.width
            useSpaceOf = "right"
        }
        if(maxDistance < root.height - hollowBlock.y - hollowBlock.height){
            maxDistance = root.height - hollowBlock.y - hollowBlock.height
            useSpaceOf = "down"
        }
        goodArea = {areaDirection: useSpaceOf, distanceToBorder: maxDistance}
//        console.log("direction:" + useSpaceOf + " distance:" + maxDistance )
    }

    function resetTutorial(){
        tutorialKey = ""
        focusItem = null//(function () { return; })(); //assign undefined in a safe way
        focusBtn = null//(function () { return; })();
        imgAutoPositioning = true
        txtAutoPositioning = true
        imageRatio = 0.7
        foggyEffect = true
        focusFrameEnabled = true
        hollowBlock.x = 0; hollowBlock.y = 0; hollowBlock.width = 0; hollowBlock.height = 0;
    }

}

