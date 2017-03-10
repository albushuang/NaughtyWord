import QtQuick 2.5
import Box2D 2.0
import QtQml 2.2
import QtQuick.Controls 1.4
import "qrc:/../UIControls"
import "ModelSettingsInInsanity.js" as Settings

/*Dont make this Rectangle as item*/
Rectangle{id: gameScreen; color: "white"
    property real objectUnitSizeRatio
    property variant obsWScale: [0, 0, 0, 0]
    property variant obsHScale: [0, 0, 0, 0]
    property real mainRoleWScale
    property real mainRoleHScale
    property real choiceWScale
    property real choiceHScale
    property real mainRoleScale: Settings.originMainRoleScale
    property real originDistance: 0
    property real currentDistance: 0
    property real lastX;
    property real lastY;
    property variant obsInitPositionX: [0, 0, 0, 0]
    property variant obsInitPositionY: [0, 0, 0, 0]
    property real initVelocityScale
    property real mainRuleBufferDistance
    property real choiceBufferDistance
    property real accelerateScale
    property int numberOfChoice
    property int score
    property string word: "question"
    property bool isImageMode: true
    property bool isLandScape: width > height

    property alias displayScreen: displayScreen
    property alias controllScreen: controllScreen
    property alias bonusView: bonusView
    property alias imageForSpellingMode: imageForSpellingMode

    signal collideObstacle()
    signal collideChoice(int index)

    width: parent.width; height: parent.height
    function initView(){
        displayScreen.initView()
        controllScreen.initView()
    }
    AutoImage{
        autoCalculateSize: false; anchors.fill: parent
        source:"qrc:/pic/insanity_background.png"
    }

    Item{
        id: displayScreen
        property alias mainRole: mainRole
        property alias obstacelArray: obstacelArray
        property alias mainRoleBody: mainRoleBody
        property alias choiceArray: choiceArray
        property int shorterSideLength: width<height ? width:height
        property real lastWidth: 0
        property real lastHeight: 0
        width: isLandScape? gameScreen.width/2: gameScreen.width
        height: isLandScape? gameScreen.height: 738*vRatio
        z: 0

        function initView(){
            obstacelArray.initObstaclePositions()
            mainRole.x = width/2 - mainRole.width/2
            mainRole.y = height/2 - mainRole.height/2
            choiceArray.resetChoices()
            mainRoleScale = Settings.originMainRoleScale
            word = ""            
        }

        Repeater{
            id: obstacelArray
            model:4
            property variant imageSources: ["insanity_rock01.png", "insanity_rock02.png",
                "insanity_rock03.png", "insanity_rock04.png"]
            property variant imgSize: [Qt.size(75,57), Qt.size(92,76), Qt.size(83,76), Qt.size(89,67)]
            property variant imgShape: [firstImgShape, secondImgShape, thirdImgShape, fourthImgShape]
            property variant firstImgShape: [Qt.point(22,2), Qt.point(55,2), Qt.point(74,16),
                Qt.point(74,37),Qt.point(55,57),Qt.point(21,56),Qt.point(1,40),Qt.point(1,17)]
            property variant secondImgShape: [Qt.point(10,12), Qt.point(60,-1), Qt.point(87,6), Qt.point(95,32),
                Qt.point(75,68), Qt.point(45,77),Qt.point(13,66),Qt.point(-2,36)]
            property variant thirdImgShape: [Qt.point(9,9), Qt.point(34,-2), Qt.point(69,9), Qt.point(82,31),
                Qt.point(80,54), Qt.point(51,73),Qt.point(18,75),Qt.point(0,55)]
            property variant fourthImgShape: [Qt.point(37,1), Qt.point(72,2), Qt.point(89,19), Qt.point(89,40),
                Qt.point(59,63), Qt.point(22,68),Qt.point(1,52),Qt.point(2,27)]
            Obstacle{
                id: obstacle
                width:displayScreen.shorterSideLength*objectUnitSizeRatio*obsWScale[index];
                height:displayScreen.shorterSideLength*objectUnitSizeRatio*obsHScale[index]
                x: Math.max(displayScreen.width*obsInitPositionX[index] - width, 0 )
                y: Math.max(displayScreen.height*obsInitPositionY[index] - height, 0 )
                imgSize: obstacelArray.imgSize[index]
                imgShape: obstacelArray.imgShape[index]
                z:2
                initVelocity: Qt.point(0,0)
                accelerateScale: 0
                imageUrl: "qrc:/pic/" + obstacelArray.imageSources[index]
            }

            function initObstaclePositions(){
                for(var i=0; i<obstacelArray.count; i++){
                    var thisObstacel = obstacelArray.itemAt(i)
                    thisObstacel.x = Math.max(displayScreen.width*obsInitPositionX[i] - thisObstacel.width, 0 )
                    thisObstacel.y = Math.max(displayScreen.height*obsInitPositionY[i] - thisObstacel.height, 0 )
                }
            }
            function obstacelStartToMove(){
                for(var i=0; i<obstacelArray.count; i++){
                    var thisObstacel = obstacelArray.itemAt(i)
                    thisObstacel.initVelocity = caculateInitVelocity(
                                thisObstacel.x + thisObstacel.width/2,thisObstacel.y + thisObstacel.height)
                    thisObstacel.accelerateScale = accelerateScale
                    thisObstacel.start()
                }
            }
            function stopAll(){
                for(var i=0; i<obstacelArray.count; i++){
                    obstacelArray.itemAt(i).working = false
                }
            }

            function resume(){
                for(var i=0; i<obstacelArray.count; i++){
                    obstacelArray.itemAt(i).working = true
                }
            }

            function caculateInitVelocity(x,y){
                var randomMidX = 0.4 + Math.random()*0.2 //Make it 0.4~0.6
                var randomMidY = 0.5 + Math.random()*0.2 //Dont know why 0.5~0.7 looks better
//                console.log("randomMidX",randomMidX); console.log("randomMidY",randomMidY)
                var vectorX = displayScreen.width*randomMidX - x
                var vectorY = displayScreen.height*randomMidY - y
                //15 means "it takes obstacle 15 second to run from one corner to another coner
                vectorX = 2*vectorX/physicsWorld.pixelsPerMeter/15*initVelocityScale
                vectorY = 2*vectorY/physicsWorld.pixelsPerMeter/15*initVelocityScale
                return Qt.point(vectorX, vectorY)
            }


            function modifyVelocityBy(percentage){
                for(var i=0; i<obstacelArray.count; i++){
                    obstacelArray.itemAt(i).obsBody.linearVelocity.x *= percentage
                    obstacelArray.itemAt(i).obsBody.linearVelocity.y *= percentage
                }
            }
            function modifySizeBy(percentage){
                for(var i=0; i<obstacelArray.count; i++){
                    obstacelArray.itemAt(i).width *= percentage
                    obstacelArray.itemAt(i).height *= percentage
                }
            }

        }

        Repeater{
            id: choiceArray
            model: numberOfChoice
            Choice{
                id: eachChoice
                width: displayScreen.shorterSideLength*objectUnitSizeRatio*choiceWScale
                z: 0
                isImageMode: gameScreen.isImageMode
            }

            function assignChoicesToRandomPosition(){
                for(var i = 0; i < numberOfChoice; i++){
                    var thisChoice = choiceArray.itemAt(i)                    
                    var thisChoiceBox = thisChoice.choiceBox
                    var x, y
                    var tryCount = 0
                    do{
                        var positionInvalid = false
                        x = Math.floor(Math.random() * (displayScreen.width - thisChoice.width))
                        y = Math.floor(Math.random() * (displayScreen.height - thisChoice.height) )

                        //It's ok that the image overlap with mainRole.
                        //But "choiceBox", a box2D object, definitely cannot overlap with mainRole.
                        var thisChoiceBoxX = x + thisChoiceBox.x    //Need to convert choiceBox coordinate to mainRole coordinate
                        var thisChoiceBoxY = y + thisChoiceBox.y
                        if(thisChoiceBoxX + thisChoiceBox.width > (mainRole.x - mainRole.width*mainRuleBufferDistance) && //check left
                           thisChoiceBoxY + thisChoiceBox.height > (mainRole.y - mainRole.height*mainRuleBufferDistance) && //check up
                           thisChoiceBoxX < (mainRole.x + mainRole.width + mainRole.width*mainRuleBufferDistance) &&     //check right
                           thisChoiceBoxY < (mainRole.y + mainRole.height + mainRole.height*mainRuleBufferDistance) ){   //check down
                            positionInvalid = true
                        }

                        //If we want to excape from infinite loops. At least make sure mainRole doesn't overlap with choiceBox
                        if(tryCount++ > 5000 && positionInvalid == true){
                            console.log("Try random position over 5000 times")
                            break
                        }

                        //For two choices, there is no collision problem. Just don't put two choice too close
                        for(var j = 0; j < i; j++){
                            var otherChoice = choiceArray.itemAt(j)
                            if(x + thisChoice.width > (otherChoice.x - otherChoice.width*choiceBufferDistance) && //check left
                               y + thisChoice.height > (otherChoice.y - otherChoice.height*choiceBufferDistance)  &&    //check up
                               x < (otherChoice.x + otherChoice.width + otherChoice.width*choiceBufferDistance) &&  //check right
                               y < (otherChoice.y + otherChoice.height + otherChoice.height*choiceBufferDistance) ){    //check down
                                positionInvalid = true                                
                            }
                        }
                    } while(positionInvalid);
                    thisChoice.x = x;
                    thisChoice.y = y;
                }
            }

            function removeChoice(thisChoice){
                thisChoice.x = displayScreen.x - thisChoice.width
                thisChoice.y = displayScreen.y - thisChoice.height
            }

            function resetChoices(){
                for(var i = 0; i < numberOfChoice; i++){
                    choiceArray.itemAt(i).source = ""
                    choiceArray.itemAt(i).letter = ""
                }
            }

            function enableCollisionWithMainRoleBy(index){
                choiceArray.itemAt(index).choiceBox.collidesWith = Box.Category2;
            }

            function disableAllCollisionWithMainRole(){
                for(var i = 0; i < numberOfChoice; i++){
                    choiceArray.itemAt(i).choiceBox.collidesWith = Box.None;
                }
            }

            function enableAllCollisionWithMainRole(){
                for(var i = 0; i < numberOfChoice; i++){
                    choiceArray.itemAt(i).choiceBox.collidesWith = Box.Category2;
                }
            }

            function enableHintAnimationBy(index){
                choiceArray.itemAt(index).startHint()
            }
            function disableAllHintAnimation(){
                for(var i = 0; i < numberOfChoice; i++){
                    choiceArray.itemAt(i).stopHint()
                }
            }
        }
        Item{
            id: mainRole
            width:mainRoleScale*(displayScreen.shorterSideLength*objectUnitSizeRatio*mainRoleWScale);
            height:mainRoleScale*(displayScreen.shorterSideLength*objectUnitSizeRatio*mainRoleHScale);
            x: parent.width/2 - width/2; y: parent.height/2 - height/2
            z: 4
            onWidthChanged: {moveEyeTimer.updateEye()}
            onHeightChanged: {moveEyeTimer.updateEye()}
            AutoImage{id: mainRoleImg
                anchors.fill: parent; autoCalculateSize: false
                source: "qrc:/pic/insanity_Alice( with bubble).png"

                AutoImage{id: eye
                    property real hRatio: parent.width/120
                    property real vRatio: parent.height/120
                    x: 56*hRatio ; y: 24.5*vRatio
                    property point center: Qt.point(56*hRatio + width/2, 24.5*vRatio + height/2)
                    property real moveDistance: 3.5*hRatio

                    source: "qrc:/pic/insanity_AliceEye.png"
                }

                Timer{id: moveEyeTimer; running: true; repeat: true; interval: 500
                    onTriggered: { updateEye() }

                    function updateEye(){
                        var minDistance
                        var eyeInDisplay = eye.mapToItem(displayScreen, eye.center.x, eye.center.y)
                        for(var i = 0; i< obstacelArray.count; i++){
                            var thisObs = obstacelArray.itemAt(i)
                            var obsCenter = Qt.point(thisObs.x + thisObs.width/2, thisObs.y + thisObs.height/2)
                            var dist = Math.sqrt(Math.pow((obsCenter.x - eyeInDisplay.x),2) +
                                                 Math.pow((obsCenter.y - eyeInDisplay.y),2))
                            if(typeof(minDistance) == "undefined" || dist < minDistance){
                                minDistance = dist
                                eye.x = eye.center.x - eye.width/2 + (obsCenter.x - eyeInDisplay.x)/dist * eye.moveDistance
                                eye.y = eye.center.y - eye.height/2 + (obsCenter.y - eyeInDisplay.y)/dist * eye.moveDistance
                            }

                        }
                    }
                }
            }

            Body{
                id: mainRoleBody
                target: mainRole
                world: physicsWorld
                bodyType: Body.Static
                fixedRotation: true
                fixtures: Circle {
                    id: mainCircle
                    radius: mainRole.width/2
                    density: 1
                    friction: 0
                    restitution: 0
                    categories: Box.Category2
                    collidesWith: Box.Category1 | Box.Category16 | Box.Category3
                    onBeginContact: {
                        if(other.categories == Box.Category1){
                            collideObstacle()
                        }
                   }
                }
            }
            function disableCollisionWithObstacle(){
                mainCircle.collidesWith &=  Box.Category16 | Box.Category3;
            }
            function enableCollisionWithObstacle(){
                mainCircle.collidesWith |= Box.Category1;
            }
        }

//        RevoluteJoint {   //This might be able to solve the collision problem (碰撞後兩物體沒有黏在一起)
//            bodyA: mainRoleBody
//            bodyB: obstacelArray.itemAt(0).obsBody
////                localAnchorA: Qt.point(600,24)
////                localAnchorB: Qt.point(24,24)
//            collideConnected: true
//            enableMotor: false
//        }
        onWidthChanged: { readjustLocationX()}
        onHeightChanged: {readjustLocationY()}

        function readjustLocationX(){
            if(lastWidth == 0 ){
                lastWidth = width
            }else if(width != lastWidth){
                mainRole.x = mainRole.x * width / lastWidth
                if(obstacelArray.count > 0
                        && obstacelArray.itemAt(0).obsBody.linearVelocity.x == 0
                        && obstacelArray.itemAt(0).obsBody.linearVelocity.y == 0 ){
                    obstacelArray.initObstaclePositions()
                }else{
                    for(var i = 0; i < obstacelArray.count; i++){
                        obstacelArray.itemAt(i).x = obstacelArray.itemAt(i).x * width / lastWidth
                    }
                }
                for(var i = 0; i < choiceArray.count; i++){
                    choiceArray.itemAt(i).x = choiceArray.itemAt(i).x * width / lastWidth
                }

                lastWidth = width
            }
        }

        function readjustLocationY(){
            if( lastHeight == 0 ){
                lastHeight = height
            }else if(height != lastHeight){
                mainRole.y = mainRole.y * height / lastHeight
                if(obstacelArray.count > 0
                        && obstacelArray.itemAt(0).obsBody.linearVelocity.x == 0
                        && obstacelArray.itemAt(0).obsBody.linearVelocity.y == 0 ){
                    obstacelArray.initObstaclePositions()
                }else{
                    for(var i = 0; i < obstacelArray.count; i++){
                        obstacelArray.itemAt(i).y = obstacelArray.itemAt(i).y * height / lastHeight
                    }
                }
                for(var i = 0; i < choiceArray.count; i++){
                    choiceArray.itemAt(i).y = choiceArray.itemAt(i).y * height / lastHeight
                }

                lastHeight = height
            }
        }

        World {
            id: physicsWorld
            gravity: Qt.point(0,0)
        }

        ScreenBoundaries {screen: displayScreen}
    }

    Item{
        id: controllScreen; z:0
        property alias fingerPrint:fingerPrint
        property alias powerUpAnimation:powerUpAnimation
        property alias questText:questText
        x:0; y: 738*vRatio
        width: parent.width; height: parent.height - y


        function initView(){
            imageForSpellingMode.source = ""
            fingerPrint.visible = true
            powerUpAnimation.cleanView()
        }

        Text{
            id: questText
            text: word; color: "white"
            width: 518*hRatio; height: 63*vRatio
            x: 32*hRatio; y:17*vRatio
            font.pointSize: 88; fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignLeft;  verticalAlignment: Text.AlignVCenter

        }
        Text{
            id: scoreText
            text: score; color: "white"
            width: 163*hRatio; height: 72*vRatio
            x: 570*hRatio; y:12*vRatio
            font.pointSize: 88; fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        Image{
            id: imageForSpellingMode            
            width: 358*hRatio; height: 358*vRatio
            x: 194*hRatio; y:146*vRatio
            source: imageForSpellingMode.source
            fillMode:  Image.PreserveAspectCrop//PreserveAspectFit
        }
        Image{
            id: fingerPrint
            width: parent.width/5; height: parent.width/3.5   //This is not typo. don't use parent.height
            rotation: -5
            opacity: 0.75
            source: "qrc:/finger.png"
//            source: "qrc:/pic/alient finger01.png"
//            source: "qrc:/pic/alient finger02.png"
            SequentialAnimation{
                id: fingerMove
                running: fingerPrint.visible
                loops: Animation.Infinite

                ParallelAnimation{
                    NumberAnimation {
                        target: fingerPrint;property: "x";duration: 1200;easing.type: Easing.InOutQuad
                        from: controllScreen.width/5;to: controllScreen.width*3/5;
                    }
                    NumberAnimation {
                        target: fingerPrint;property: "y";duration: 1200;easing.type: Easing.InOutQuad
                        from: controllScreen.height/5;to: controllScreen.height*2/5;
                    }
                }
                ParallelAnimation{
                    NumberAnimation {
                        target: fingerPrint;property: "x";duration: 1200;easing.type: Easing.InOutQuad
                        from: controllScreen.width*3/5;to: controllScreen.width/5;
                    }
                    NumberAnimation {
                        target: fingerPrint;property: "y";duration: 1200;easing.type: Easing.InOutQuad
                        from: controllScreen.height*2/5;to: controllScreen.height*3/5;
                    }
                }
            }
        }

        PowerUpAnimation{
            id: powerUpAnimation
            z: 3
            width: displayScreen.shorterSideLength/10; height: width*146/128
            //Make init point in the middle of displayScreen
            initPoint.x: isLandScape ? -(displayScreen.width/2 + width/2) : (displayScreen.width/2 - width/2)
            initPoint.y: isLandScape ? (displayScreen.height/2 - height/2):-(displayScreen.height/2 + height/2)
            isLandScape: gameScreen.isLandScape
//            animTargetPoint:Qt.point(-x,-y + 104*vRatio);
            animTargetPoint:Qt.point(5*hRatio, 108*vRatio);
        }

    }
    Item{
        id: bonusView
        property alias bonus: bText.text
        property alias scaleAnimaiton:scaleAnimaiton
        anchors.centerIn: gameScreen
        width: parent.width/8; height: parent.height/8
        Text{
            id: bText
            color: text.indexOf("+") != -1 ? "white" : "#4DB84D" //Green
            width: parent.width; height: parent.height
            font.pointSize: 100
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        ParallelAnimation{
            id: scaleAnimaiton
            PropertyAnimation{target: bText; duration: 500; property: "scale"; from: 1; to:6}
            SequentialAnimation{
                PropertyAnimation{target: bText; duration: 300; property: "opacity"; from: 0.2; to:0.7}
                PropertyAnimation{target: bText; duration: 200; property: "opacity"; from: 0.7; to:0}
            }
        }
    }
}
