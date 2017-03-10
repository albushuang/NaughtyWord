import QtQuick 2.0
Item{id: root
    property real widthRatio: 0.9
    property real heightRatio: 0.9
/*Important! In order to use this FloatWindow, you must make sure that targetItem was
originally anchored (fill) to it's parent. Please see the example of WordDetail.imageArea*/
    property variant targetItem
    signal backgroundClicked()
    visible: false

    anchors.fill: parent
    property variant targetInfo

    onWidthChanged: {
        if(visible){
            targetItem.x = width * (1 - widthRatio) / 2
            targetItem.width = width * widthRatio
        }
    }

    onHeightChanged: {
        if(visible){
            targetItem.y = height * (1 - heightRatio) / 2
            targetItem.height = height * heightRatio
        }
    }

    Rectangle {id: grayBackground; anchors.fill: parent
        color: "Gray"; opacity: 0.8
        MouseArea{anchors.fill: parent; onClicked: {backgroundClicked()}}
    }

    NumberAnimation{id: showAnim; target: root; property: "scale"; from: 0; to: 1; duration: 300}
//    NumberAnimation{id: endAnim; target: root; property: "scale"; from: 1; to: 0; duration: 300}

    function show(){
        saveTargetInfo()
        positionTarget()
        showAnim.start()
        visible = true
    }

    function end(){
        visible = false
        retrieveTargetInfo()
    }

    function saveTargetInfo(){
        targetInfo = {
            parent: targetItem.parent}
    }

    function retrieveTargetInfo(){
        targetItem.parent = targetInfo.parent

        targetItem.x = 0
        targetItem.y = 0
        targetItem.width = 0
        targetItem.height = 0
        targetItem.anchors.fill = targetItem.parent
    }



    function positionTarget(){
        setAnchorUndefined(targetItem)
        targetItem.x = width * (1 - widthRatio) / 2
        targetItem.y = height * (1 - heightRatio) / 2
        targetItem.width = width * widthRatio
        targetItem.height = height * heightRatio
        targetItem.parent = root
    }

    function setAnchorUndefined(tar){
        var undef = (function (){ return;})()

        tar.anchors.fill = undef
    }

}
