import QtQuick 2.0

Item {id: root; z: 2
/*Public memebers*/
    property ListModel menuModel //[Mandatory]
    property alias menuDelegate: theView.delegate //[Mandatory]
    property alias highlight: theView.highlight //[Optional]
    property alias currentIndex: theView.currentIndex //[Optional]
    property alias spacing: theView.spacing //[Optional]
/*enumDirection.up || enumDirection.down || enumDirection.left || enumDirection.right */
    property alias enumDirection: moveAnim.enumDirection //[ReadOnly]
    width: parent.width //[Optional]
    height: (theView.count > 0 && theView.currentItem) ? //[Optional]
            (theView.currentItem.height*theView.count + (theView.count - 1)* spacing) : 0
    signal itemClicked(int id, int index)
    signal backgroundClicked()

    function show(direction){ /*direction's type is enumDirection*/
        moveAnim.direction = direction
        visible = true
        moveAnim.show()
    }

    function end(){ /*Use the direction in show(). No need to assign again*/
        moveAnim.end()
    }

/*Private memebers*/
    QtObject{id: own
    }

    MoveAnimation{id: moveAnim
        target: root
    }

    ListView { id: theView
        model: menuModel
        delegate: theDelegate
        anchors.fill: parent
        spacing: 0
        currentIndex: 0
        z: 10
    }
    Item{id: mouseStealer; visible: root.visible; z: 1
        parent: root.parent; anchors.fill: parent
        MouseArea{ anchors.fill: parent; onClicked: {end()}}
    }
    visible: false;  clip: false

}

