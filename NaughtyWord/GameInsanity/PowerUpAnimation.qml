import QtQuick 2.0
import "settingValues.js" as Value
import "qrc:/../UIControls"

Item {//To use this item, please define the widthe and height
    id: rootItem
    property string powerUp: ""
    property point animTargetPoint
    property point initPoint
    property bool isLandScape
    property variant permanentPowerUp: []
    property alias randomImg: randomImg

/* 3,2,1 count donw code
    Text{
        id: hintText
        text:""
        color: "#75FF47" //Green
        width: parent.width; height: width; anchors.centerIn: parent;
        font.pixelSize: 666; fontSizeMode: Text.Fit; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }
*/


    Repeater{
        id: powerUpArray
        model: myModel
        property int positionBits: 0


        AutoImage{
            id: hintImage
            width: rootItem.width; height: rootItem.height;
            source: "qrc:/pic/insanity_" + powerUp + "_icon.png";
            x:initPoint.x; y:initPoint.y;
            property int location: -1
            property alias newPowerUpAnim:newPowerUpAnim

            ParallelAnimation{ id: newPowerUpAnim
                NumberAnimation {target: hintImage; properties: "x"; duration: 600; easing.type: Easing.InOutCubic;
                    from:initPoint.x; to: isLandScape? animTargetPoint.x : animTargetPoint.x + hintImage.location*width; }
                NumberAnimation {target: hintImage; properties: "y"; duration: 600; easing.type: Easing.InOutCubic
                    from:initPoint.y; to: isLandScape? animTargetPoint.y + hintImage.location*height : animTargetPoint.y;}
                onStopped: {
                    for(var i = 0; i < permanentPowerUp.length; i++){
                        if(powerUp == permanentPowerUp[i]){
                            powerUpArray.positionBits &= (1023 - (1<<hintImage.location).valueOf())
                            myModel.remove(index,1);
                            break;
                        }
                    }
                }
            }

            SequentialAnimation{ id: endPowerUpAnim
                loops: timer != -1 ? timer/1000 : 0
                running: timer != -1
                NumberAnimation {target: hintImage; properties: "opacity"; duration: 500; easing.type: Easing.InOutCubic;
                    from: 1; to: 0; }
                NumberAnimation {target: hintImage; properties: "opacity"; duration: 500; easing.type: Easing.InOutCubic
                    from: 0; to: 1;}
                onStopped: {
                    if(timer != -1){
                        powerUpArray.positionBits &= (1023 - (1<<hintImage.location).valueOf())
                        myModel.remove(index, 1);
                    }
                }
            }

            AutoImage{
                autoCalculateSize: false; anchors.fill: parent
                source: "qrc:/pic/insanity_photo frame (white).png"
            }

            onSourceChanged: {
                if(location == -1){
                    for(var i = 0; i< 10; i ++){
                        if((powerUpArray.positionBits & 1<<i) == 0){
                            powerUpArray.positionBits |= 1<<i;
                            hintImage.location = i;
                            break;
                        }
                    }
                }
                newPowerUpAnim.start()
            }
        }
    }
    ListModel{ id: myModel }

/* 3,2,1 count donw code
    Timer{
        running: powerUp != ""
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(hintText.text == "1"){
                var idx = rootItem.findIndexInModel(powerUp);
                if(idx == -1){
                    myModel.append({powerUp: powerUp, timer: -1});
                }else{
                    powerUpArray.itemAt(idx).newPowerUpAnim.start();
                    myModel.get(idx).timer = -1
                }

                powerUp = "";

            }else{
                 textAnim.start(); hintText.text -= 1;
//                greenAnim.start();
            }
        }     
    }
*/

    AutoImage{
        id: randomImg
        property string randPowerUp:""
        x: initPoint.x; y:initPoint.y
        width: rootItem.width; height: rootItem.height;
        source: randPowerUp != "" ? "qrc:/pic/insanity_" + randPowerUp + "_icon.png" : "";
//        onSourceChanged: {
//            imgAnim.start()
//        }
        NumberAnimation on opacity{id: imgAnim ;from:1; to: 0; duration: animTimer.interval;}
    }
    Timer{id: animTimer
        interval: 1000; repeat: true
        property int excuteNum
        property int counter: 0
        triggeredOnStart: true
        onTriggered: {            
            if(counter < excuteNum){
//                randomImg.randPowerUp = randomizePowerUp(randomImg.randPowerUp)
                randomImg.randPowerUp = powerUp
                imgAnim.start()
                counter++;
            }else{
                randomImg.randPowerUp = ""
                var idx = rootItem.findIndexInModel(powerUp);
                if(idx == -1){
                    myModel.append({powerUp: powerUp, timer: -1});
                }else{
                    powerUpArray.itemAt(idx).newPowerUpAnim.start();
                    myModel.get(idx).timer = -1
                }
                animTimer.stop()
                counter = 0
            }            
        }
        function randomizePowerUp(currPowerUp){
            var possiblePowerUp = [Value.teacher, Value.smart, Value.invisible,
                                   Value.gravity, Value.shrinker, Value.redBull];
            var newPowerUp = "";
            do{
                newPowerUp = possiblePowerUp[Math.floor(Math.random() * possiblePowerUp.length )];
            }while(newPowerUp == currPowerUp)
            return newPowerUp;
        }
    }

    function newPowerUp(newPowerUp, milliSec){
        powerUp = newPowerUp;
        animTimer.excuteNum = milliSec / animTimer.interval;
        animTimer.start()
/*3,2,1 count donw code          hintText.text = milliSec/1000 + 1;*/
    }

    function endPowerUp(oldPowerUp, milliSec){
        var idx = findIndexInModel(oldPowerUp);
//        console.log("milliSec", milliSec)
        myModel.get(idx).timer = milliSec
    }

    function findIndexInModel(powerUp){
        for(var i = 0; i < myModel.count; i++){
            if(myModel.get(i).powerUp == powerUp){
                return i;
            }
        }
        return -1;
    }

    function cleanView(){
        myModel.clear();
        randomImg.randPowerUp = ""
        powerUpArray.positionBits = 0;
    }
}

