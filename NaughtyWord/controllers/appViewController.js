.import com.glovisdom.NWPleaseWait 0.1 as Wait
//.import "../generalJS/objectCreate.js" as Create
//.import com.glovisdom.UserSettings 0.1 as US
var NWPleaseWait = Wait.NWPleaseWait

//If you don't want "PleaseWait" animetion. You can call switchControlWithIdReturned() instead
function switchControl(qml,properties,immediate,replace,destroyOnPop,direct) {
    NWPleaseWait.callbackAfterForceRedraw = function(){
        if(stackView.busy == false){
            stackView.direct= typeof(direct) == "undefined" ? stackView.direct : direct
            stackView.push({item: Qt.resolvedUrl(qml),
                                 properties: properties,
                                 immediate: immediate,
                                 replace: replace,  //true,
                                 destroyOnPop: destroyOnPop,})
        }
        NWPleaseWait.state = "stopped"
        NWPleaseWait.visible = false
        NWPleaseWait.callbackAfterForceRedraw = (function (){return})()
    }
    NWPleaseWait.message = ""
    NWPleaseWait.visible = true;
    NWPleaseWait.state = "running";
}


//If you want to get return id, you have to handle NWPleaseWait by yourself
function switchControlWithIdReturned(qml,properties,immediate,replace,destroyOnPop,direct){
    var id;

    if(stackView.busy == false){
        stackView.direct= typeof(direct) == "undefined" ? stackView.direct : direct
        id = stackView.push({item: Qt.resolvedUrl(qml),
                             properties: properties,
                             immediate: immediate,
                             replace: replace,  //true,
                             destroyOnPop: destroyOnPop,})
    }
    return id;
}

function popCurrentView(item) {
    stackView.pop(item);
}

function popCurrentViewNoTransit(someItem) {
    stackView.pop({item:someItem, immediate: true});
}

function getLastView(){
    return stackView.get(stackView.depth-1)
}

function makePreviousVisible() {
    var previous = stackView.get(stackView.depth-2);
    previous.visible = true;
}

function makePreviousInvisible () {
    var previous = stackView.get(stackView.depth-2);
    previous.visible = false;
}


function connectStackViewItem(func) {
    stackView.onCurrentItemChanged.connect(func);
}

function disconnectStackViewItem(func) {
    stackView.onCurrentItemChanged.disconnect(func);
}

function getDepth() {
    return stackView.depth
}

//function getDirection(reminder, direction) {
//    switch (direction) {
//    case "left": return reminder.enumDirection.left;
//    case "right": return reminder.enumDirection.right;
//    case "up": return reminder.enumDirection.up;
//    case "down": return reminder.enumDirection.down;
//    }
//    return reminder.enumDirection.right
//}

//function remindDragToRight(parent, cancel, duration, direction) {
//    var prop = {
//        reminderType: US.UserSettings.remindTypeDragToExit,
//        remindCancelOption: cancel,
//        reminderDuration: duration,
//    }
//    var text = qsTr("Drag right to go back.")
//    var reminder = Create.instantComponent(parent, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
//    reminder.cycleEndCallback = reminder.destroy
//    reminder.visible = parent.parent.visible
//    reminder.showReminder(text, getDirection(reminder, direction))
//    reminder.noRemindClicked.connect(noRemindClicked)
//}

//function noRemindClicked(type){
//    US.UserSettings.dragToExitRemind = false
//}
