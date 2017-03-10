import QtQuick 2.0

MouseArea { id: hmouse
    property var target;
    property real maxX;
    property int msDuration: 800
    property int frameRate: 30
    property var toLeftToDo
    property var toRightToDo
    property var dragToDo

    anchors.fill: parent    //Try full screen. Not sure if there will be any problem
//    width: parent.width*3/12; height: parent.height

    onPressed: { pressedOnEdge(mouse) }
    onReleased: { releasedOnEdge(mouse) }
    drag.axis: Drag.XAxis
    drag.minimumX: 0
    drag.target: target;
    drag.maximumX: maxX;
    drag.filterChildren: true
    drag.threshold: 0
    function setExtensionMouse(extMouse){
        extMouse.onPressed.connect(pressedOnEdge)   //Stupid design that pressed is not only a signal but also a property
        extMouse.released.connect(released)
        extMouse.drag.axis = drag.axis
        extMouse.drag.minimumX = drag.minimumX  /*binding those property needed to be bound*/
        extMouse.drag.target = Qt.binding(function (){return drag.target})
        extMouse.drag.maximumX = Qt.binding(function (){return maxX})
        extMouse.drag.filterChildren = drag.filterChildren
        extMouse.drag.threshold = drag.threshold
    }

    QtObject { id: own
        property var callBack
        property bool isSwipe: true
        property point pressPoint
        property point releasePoint
    }

    Timer{id: swipeTimer; interval: 300
        onTriggered: {own.isSwipe = false}
    }

    function pressedOnEdge(mouse) {
        /*When dragging target, target's x is changing. If target is dragMouse's parent, the related coordinate point
         between mouse and mouse's parent is not meaningful. We need to convert it to target's parent coordinate system*/
        own.pressPoint =  mapToItem(target.parent, mouse.x, mouse.y)
//        console.log("Press point", own.pressPoint.x, own.pressPoint.y)
        own.isSwipe = true
        swipeTimer.restart()
        animateX.stop()
        dragToDo(); //ViewController.makePreviousVisible();
    }
    function releasedOnEdge(mouse) {
        own.releasePoint =  mapToItem(target.parent, mouse.x, mouse.y)
//        console.log("Release point", own.releasePoint.x, own.releasePoint.y)
        animateX.from = target.x;
        if(own.isSwipe){
            if((own.releasePoint.x - own.pressPoint.x > target.parent.width*0.1)){
                toRight();
            }else{ toLeft()}
        }else{
            if(target.x > target.parent.width/2) { toRight()
            } else { toLeft() }
        }
        animateX.restart()
    }
    function toLeft(){
        animateX.to = 0;
        own.callBack = toLeftToDo//ViewController.makePreviousInvisible;
    }
    function toRight(){
        animateX.to = target.parent.width;
        own.callBack = function(){return}
        toRightToDo();
        //ViewController.popCurrentView();

//        own.callBack = ViewController.popCurrentViewNoTransit
         /*In callBack solution as above. If user remove last view and immediately (before animetion finish) push
         a new view, new view will be popped */
    }

    NumberAnimation { id: animateX
        target: hmouse.target
        properties: "x"
        easing {type: Easing.OutBack; }
        onStopped: { own.callBack(); }
        duration: msDuration
   }

}

