import QtQuick 2.0

// delegations
// clickedOnLeftBtn(), clickedOnRightBtn(), clickedOnUpBtn(), clickedOnDownBtn()
Item {id: root
    property var delegator
    property string lImgUrl:""
    property string rImgUrl:""
    property string uImgUrl:""
    property string dImgUrl:""

    anchors.fill: parent

    Image { id: lBtn
        source: lImgUrl
        anchors{ left: parent.left; verticalCenter: parent.verticalCenter }
        width: parent.width/10;
        height: width*sourceSize.height/sourceSize.width
        opacity: 0.8
        visible: lImgUrl!=""
        MouseArea {
            anchors.fill: parent
            onClicked: delegator.clickedOnLeftBtn();
        }
    }
    Image { id: rBtn
        source: rImgUrl
        anchors{ right: parent.right; verticalCenter: parent.verticalCenter }
        width: parent.width/10;
        height: width*sourceSize.height/sourceSize.width
        visible: rImgUrl!=""
        opacity: 0.8
        MouseArea {
            anchors.fill: parent
            onClicked: delegator.clickedOnRightBtn();
        }
    }
    Image { id: uBtn
        source: uImgUrl
        anchors{ top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: parent.width/10;
        height: width*sourceSize.height/sourceSize.width
        visible: uImgUrl!=""
        opacity: 0.8
        MouseArea {
            anchors.fill: parent
            onClicked: delegator.clickedOnUpBtn();
        }
    }
    Image { id: dBtn
        source: dImgUrl
        anchors{ bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: parent.width/10;
        opacity: 0.8
        height: width*sourceSize.height/sourceSize.width
        visible: dImgUrl!=""
        MouseArea {
            anchors.fill: parent
            onClicked: delegator.clickedOnDownBtn();
        }
    }
}

