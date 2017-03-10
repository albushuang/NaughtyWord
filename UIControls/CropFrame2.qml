import QtQuick 2.4

Rectangle { id: frame
    property bool square: false
    property real minX;
    property real maxX;
    property real minY;
    property real maxY;
    property int boxSize: 45*hRatio
    color: "transparent"
    radius: 0
    border.width: 2
    border.color: "yellow"

    MouseArea {
        anchors.fill: parent
/*Remove drag for 3d touch*/
        drag.axis: Drag.XAndYAxis
        drag.target: frame
        drag.minimumX : minX
        drag.maximumX : maxX-parent.width
        drag.minimumY : minY
        drag.maximumY : maxY-parent.height
//        drag.threshold: Qt.platform.os == "ios" ? 10 : drag.threshold     //set a threshold for 3d touch bug
        propagateComposedEvents: true
        onClicked:{mouse.accepted = false}
//        Component.onCompleted: {
//            if(Qt.platform.os != "ios"){
//                drag.axis = Drag.XAndYAxis
//                drag.target = frame
//                drag.minimumX = Qt.binding(function (){return minX})
//                drag.maximumX = Qt.binding(function (){return maxX-parent.width})
//                drag.minimumY = Qt.binding(function (){return minY})
//                drag.maximumY = Qt.binding(function (){return maxY-parent.height})
//            }
//        }
    }

    Repeater { id: repeat
        model: 4
        property var aligns: [tlMouseArea, trMouseArea, blMouseArea, brMouseArea ]
        Rectangle {
            width: boxSize; height: boxSize
            color: frame.border.color
            opacity: 0.3
            anchors.fill: repeat.aligns[index]
            visible: frame.width != 0
        }
    }

    MouseArea { id: tlMouseArea
        property int oldMouseX
        property int oldMouseY

        anchors { left: parent.left; top: parent.top }
        width: boxSize; height: boxSize
        onPressed: { oldMouseX = mouseX; oldMouseY = mouseY }
        onPositionChanged: {
            if (pressed) {
                var dx = mouseX-oldMouseX
                var dy = mouseY-oldMouseY
                if(square) {
                    if (dx>dy) { dy = dx }
                    else { dx = dy }
                }
                var addx = 0
                var addy = 0
                if(frame.x + dx < minX) { addx = minX - (frame.x + dx) }
                if(frame.y + dy < minY) { addy = minY - (frame.y + dy) }
                if(square) {
                    if (addx>addy) { addy = addx }
                    else { addx = addy }
                }
                dx+=addx
                dy+=addy

                frame.x += dx
                frame.y += dy
                frame.width -= dx
                frame.height -= dy
            }
        }
    }

    MouseArea { id: brMouseArea
        property int oldMouseX
        property int oldMouseY

        anchors { right: parent.right; bottom: parent.bottom }
        width: boxSize; height: boxSize
        onPressed: { oldMouseX = mouseX; oldMouseY = mouseY }
        onPositionChanged: {
            if (pressed) {
                var dx = mouseX - oldMouseX
                var dy = mouseY - oldMouseY
                if (frame.x + frame.width + dx > maxX) { dx = maxX-frame.width-frame.x}
                if (frame.y + frame.height + dy > maxY) { dy = maxY-frame.height-frame.y}
                frame.width = frame.width + dx
                frame.height = frame.height + dy
                if(square) {
                    if (frame.width > frame.height) frame.width = frame.height
                    else frame.height = frame.width
                }
            }
        }
    }

    MouseArea { id: blMouseArea
        property int oldMouseX
        property int oldMouseY

        anchors { left: parent.left; bottom: parent.bottom }
        width: boxSize; height: boxSize
        onPressed: { oldMouseX = mouseX; oldMouseY = mouseY }
        onPositionChanged: {
            if (pressed) {
                var dx = mouseX-oldMouseX
                var dy = mouseY-oldMouseY
                var nw, nx, nh
                if (frame.x + dx < minX) {
                    nw = frame.x+frame.width - minX;
                    nx = minX;
                } else {
                    nx = frame.x + dx;
                    nw = frame.width - dx
                }
                if (frame.height + frame.y + dy > maxY) { nh = maxY-frame.y }
                else { nh = frame.height + dy }

                if (square) {
                    if (nw > nh) {
                        nx += nw - nh
                        nw = nh
                    } else { nh = nw }
                }
                frame.x = nx
                frame.width = nw
                frame.height = nh
            }
        }
    }
    MouseArea { id: trMouseArea
        property int oldMouseX
        property int oldMouseY

        anchors { right: parent.right; top: parent.top }
        width: boxSize; height: boxSize
        onPressed: { oldMouseX = mouseX; oldMouseY = mouseY }
        onPositionChanged: {
            if (pressed) {
                var nw, nh, ny
                var dx = mouseX-oldMouseX
                var dy = mouseY-oldMouseY
                ny = frame.y + dy
                nw = frame.width + dx
                nh = frame.height - dy
                if (frame.x+nw > maxX) nw = maxX-frame.x
                if (ny<minY) { ny = minY; nh = frame.y+frame.height-minY }
                if(square) {
                    if (nw>nh) {
                        nw = nh
                    } else {
                        ny += nh-nw
                        nh = nw
                    }
                }
                frame.y = ny
                frame.width = nw
                frame.height = nh
            }
        }
    }
}
