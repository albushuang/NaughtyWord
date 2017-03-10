import QtQuick 2.0
import "qrc:/../../UIControls"
import "../GameTOEICBattle/settingValues.js" as MainValues
Item{id: root
    property alias numberOfCoins: coins.model   //[Mandatory]
    property point center   //[Mandatory] the center position of that pile of coins
    property real coinWidth: 50*hRatio  //[Optional]
    property real coinHeight: 50*vRatio //[Optional]
    property real stackWidth    //[Mandatory]   The width of that pile of coins
    property real stackHeight   //[Mandatory]
    property var runPaths   //[Mandatory] This is a relevant position to center. For example, [(0,0), (1,1), (2,0)]
    property int runDuration: 1000 //[Optional]
    property bool disappreaInTheEnd: true //[Optional]
    property var coinImgs  //[Mandatory] the sequence image you must assign

    signal stopped()

    function start(){
        own.reset()
        coinRun.start()
    }


    Repeater{id: coins
        SpiningCoin{id: coin
            width: coinWidth; height: coinHeight
            coinImgs: root.coinImgs
            BezierAnimation { id: bezierAnim; duration: runDuration
                target: coin
                onStopped: {
                    if(disappreaInTheEnd){
                        disappearAnim.start()
                    }else{
                        if(index == coins.model -1 ){
                            root.stopped()
                        }
                    }
                }
            }
            PropertyAnimation{id: disappearAnim; duration: 250
                target: coin; property: "opacity"
                to: 0
                onStopped: { if(index == coins.model -1 ){root.stopped()}}
            }

            function start(){
                rotateTimer.start()
//                console.log(runPaths[0].x, runPaths[0].y, runPaths[1].x, runPaths[1].y, runPaths[2].x, runPaths[2].y)
                bezierAnim.points = [Qt.point(coin.x + runPaths[0].x, coin.y + runPaths[0].y),
                              Qt.point(coin.x + runPaths[1].x, coin.y + runPaths[1].y) ,
                              Qt.point(coin.x + runPaths[2].x, coin.y + runPaths[2].y)]
                bezierAnim.start()
            }
        }
    }

    Timer{id: coinRun
        interval: 120; repeat: true
        property int count: 0
        onTriggered:{
            if(count < coins.model){
                coins.itemAt(count).start()
                count++
            }else{
                stop()
            }
        }
    }

    QtObject{id: own

        function reset(){
            root.visible = true
            coinRun.count = 0
            for(var i = 0; i < coins.model; i++){
                coins.itemAt(i).visible = true
                coins.itemAt(i).opacity = 1
                coins.itemAt(i).x = center.x + Math.random()*stackWidth*2 - stackWidth - coinWidth/2
                coins.itemAt(i).y = center.y + Math.random()*stackHeight*2 - stackHeight - coinHeight/2
            }
        }
    }
}
