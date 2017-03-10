import QtQuick 2.0
import "ViewSettingsInLingoPractice.js" as Settings
import "qrc:/../UIControls"

Item{
    id: arrowSign
    property string textContent
    property string direction: "up"
    property point pressedPoint
    readonly property int arrowSeparateWidth: 100*hRatio
    x: pressedPoint.x - canvas.width/2
    y: pressedPoint.y - canvas.height - arrowSeparateWidth/2

    transform: Rotation {
        origin.x: canvas.width/2
        origin.y: canvas.height + arrowSeparateWidth/2
        angle:{
            switch(direction){
            case "up": 0
                break
            case "right": 90
                break
            case "down": 180
                break
            case "left": 270
                break
            }
        }
    }

    AutoImage{id: canvas
        source: "qrc:/pic/Practice_arrow.png"
        width: 134*hRatio; height: 204*vRatio
    }

//    Canvas {
//        id: canvas
//        width: arrowSign.arrowSize * 6; height: arrowSign.arrowSize * 6

//        onPaint: {
//            var arrowLine = [
//            //    0 1 2 3 4 5 6
//            //    -------------
//            // 0|       o
//            // 1|     x   x
//            // 2|   x       x
//            // 3| o x o   o x o
//            // 4|     x   x
//            // 5|     x   x
//            // 6|     o x o
//                    Qt.point(3,0),
//                    Qt.point(0,3),
//                    Qt.point(2,3),
//                    Qt.point(2,6),
//                    Qt.point(4,6),
//                    Qt.point(4,3),
//                    Qt.point(6,3),
//                    Qt.point(3,0)]
//            var ctx = getContext("2d");
//            ctx.save();
//            ctx.clearRect(0,0,arrowSign.width, arrowSign.height);

//            var grd=ctx.createLinearGradient(0,0,0,arrowSign.arrowSize * 6)
//            grd.addColorStop(0,"#0099FF")
//            grd.addColorStop(0.4,"#4DB8FF")
//            grd.addColorStop(1,"#E6F5FF")
//            ctx.fillStyle = grd

//            ctx.globalAlpha = 1
//            ctx.beginPath();
//            ctx.moveTo(arrowSign.arrowSize * arrowLine[0].x, arrowSign.arrowSize * arrowLine[0].y)
//            for(var i = 1; i < arrowLine.length; i++){
//                ctx.lineTo(arrowSign.arrowSize*arrowLine[i].x, arrowSign.arrowSize*arrowLine[i].y)
//            }
//            ctx.closePath();
//            ctx.fill();
//            ctx.restore();
//        }
//    }

    Text{id: textId
        width: contentWidth; height: 39*vRatio
        anchors{horizontalCenter: canvas.horizontalCenter; verticalCenter: canvas.verticalCenter;
            verticalCenterOffset: (direction == "up" || direction == "down") ? -52*vRatio : 0
        }

        text: textContent
        color: "white"
        font.pointSize: 1000; font.bold: true
        fontSizeMode: Text.VerticalFit
        horizontalAlignment: Text.AlignHCenter ;verticalAlignment: Text.AlignVCenter
        transform: Rotation {
            origin.x: textId.width/2
            origin.y: textId.height/2
            angle:{
                switch(direction){
                case "up": 0
                    break
                case "right": 270
                    break
                case "down": 180
                    break
                case "left": 90
                    break
                }
            }
        }
    }

}

