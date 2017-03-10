import QtQuick 2.0
Item{id: root;
/*Public memebers*/
    property alias enumDirection: enumDirection
    property int direction: enumDirection.up  //[optional] Assign direction with enumDirection
    property alias target: moveAnim.target //[optional]
    property alias duration: moveAnim.duration //[optional]
    signal allStopped();
    QtObject{id: enumDirection
        readonly property int up:0
        readonly property int down:1
        readonly property int right:2
        readonly property int left:3
    }
    function show(){
        moveAnim.show()
    }

    function end(){
        moveAnim.end()
    }

/*Private memebers*/
    NumberAnimation {id: moveAnim
        target: root.parent
        duration: 350 //[optional]
        function show(){
            switch (direction){
                case enumDirection.up:
                    from = target.parent.height;
                    to = target.parent.height - target.height
                    break
                case enumDirection.down:
                    from = -target.height
                    to = 0
                    break
                case enumDirection.left:
                    from = target.parent.width
                    to = target.parent.width - target.width
                    break
                case enumDirection.right:
                    from = -target.width
                    to = 0
                    break
            }
            isShow = true
            start()
        }

        function end(){
            var tempFrom = from
            from = to; to = tempFrom
            isShow = false
            start()
        }



        property: (direction == enumDirection.up || direction == enumDirection.down) ? "y" : "x"

        property bool isShow: true
        onStopped: {
            target.visible = (moveAnim.isShow == true ? true:false)
            allStopped();
        }
    }


}
