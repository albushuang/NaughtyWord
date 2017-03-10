import QtQuick 2.0

// delegations
// clickedOnLeftBtn(), clickedOnRightBtn(), clickedOnUpBtn(), clickedOnDownBtn()
ButtonNavi {id: root
    property var dragTarget
    property var toLeftToDo
    property var toRightToDo
    property var dragToDo
    property bool dragExit: true
    signal mpressed(int x, int y)
    signal mreleased(int x, int y)
    signal xMoved(int x, int y)
    signal yMoved(int x, int y)

    DragMouse {
        target: dragTarget
        maxX: dragTarget.width
        toLeftToDo: root.toLeftToDo
        toRightToDo: root.toRightToDo
        dragToDo: root.dragToDo
        visible: dragExit
    }

    MouseArea {
        property bool newEvent: false
        property var org
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: {
            org = [mouse.x, mouse.y];
            mpressed(mouse.x, mouse.y)
        }
        onMouseXChanged: { xMoved(mouse.x, mouse.y) }
        onMouseYChanged: { yMoved(mouse.x, mouse.y) }

        onReleased: {
            if (org[0] - mouse.x > 50) { delegator.clickedOnRightBtn(mouse.x-org[0]) }
            else if (org[0] - mouse.x < -50) { delegator.clickedOnLeftBtn(mouse.x-org[0]) }
            if (org[1] - mouse.y > 20) { delegator.clickedOnDownBtn(mouse.y-org[1]) }
            else if (org[1] - mouse.y < -20) { delegator.clickedOnUpBtn(mouse.y-org[1]) }
            mreleased(mouse.x, mouse.y)
        }
        onClicked: { mouse.accepted = false }
        onDoubleClicked: { mouse.accepted = false }
    }
}

