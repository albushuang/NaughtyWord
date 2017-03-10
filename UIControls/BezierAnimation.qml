import QtQuick 2.0

Item {id: root

    property variant target
    property int duration:1000
    property variant points: []     //assign three Qt.points.  For ex: [Qt.point(0,0), Qt.point(100,100), Qt.point(200,0)]
    property bool autoRun: false    //If you set new points, animation run automatically
    signal stopped();
/*
Public Method:
    start()
    stop()
*/

    Timer{id: animTimer
        property int numberOfAnimPoints: duration/1000*60   //60 animation points per second
        property int count:0
        interval: duration/numberOfAnimPoints
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            var fromPoint = bezierTransform(count/numberOfAnimPoints)
            var toPoint = bezierTransform((count+1)/numberOfAnimPoints)
            target.x = toPoint.x; target.y = toPoint.y
            if(count == numberOfAnimPoints -1){root.stop()}
            count++;
        }
    }
    //B(t) = (1-t)^2*P0 + 2t(1-t)*P1 + t^2*P2    //t belong [0,1]
    function bezierTransform(t){
        var x = (1-t)*(1-t)*points[0].x + 2*t*(1-t)*points[1].x + t*t*points[2].x
        var y = (1-t)*(1-t)*points[0].y + 2*t*(1-t)*points[1].y + t*t*points[2].y
        return Qt.point(x,y)
    }

    function start(){
        animTimer.count = 0;
        animTimer.start()
    }
    function stop(){
        animTimer.stop();
        stopped();
    }
    onPointsChanged: {
        if(autoRun){
            start()
        }
    }
}

