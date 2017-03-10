import QtQuick 2.5
import "../GameTOEICBattle/settingValues.js" as MainValue


/*README: This is a single coin component. If you want to use a pile of coins with animetion.
Use AnimCoins.qml*/

Item {id: root
    property alias rotateTimer: rotateTimer
    property var coinImgs: []
    width: 40; height:40

    Repeater{id: imgs
        model: coinImgs.length
        Image{
            width: root.width*sourceSize.width/170; height: root.height
            visible: false
            x: (root.width - width)/2
            source: coinImgs[index]
        }
    }

    transform: Rotation {
        id: rotation
        origin.x: root.width/2
        origin.y: root.height/2
        axis.x: 0; axis.y: 0; axis.z: 1
        /*http://jsfiddle.net/Guffa/tvt5K/     The probability distrubtion is a pyramid*/
        angle: Math.random()*20 - Math.random()*20    // the default angle
    }

//    NumberAnimation {
//        target: rotation; property: "angle"; duration: 600
//        from: 0; to: 360
//        loops: Animation.Infinite; running: true
//    }

    Timer{ id: rotateTimer;  interval: 50; repeat: true;
        property int count: 0
        property string operation: "+"
        onTriggered:{
            imgs.itemAt(count).visible = false
            if(count == coinImgs.length - 1){
                operation = "-"
            }else if(count == 0){
                operation = "+"
            }

            if(operation == "+"){
                count++
                imgs.itemAt(count).rotation = 0
            }else{   //五張圖只有轉180度(半圈)，剩下半圈靠倒會來顯示圖片(外加180 rotation）來完成
                count--
                imgs.itemAt(count).rotation = 180
            }
            imgs.itemAt(count).visible = true
        }
    }
}

