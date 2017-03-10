import QtQuick 2.0
import "qrc:/../../UIControls"
import "../generalJS/objectCreate.js" as Create
import com.glovisdom.UserSettings 0.1

DragMouse { id: hmouse
    property bool remindCancelOption
    property int reminderDuration
    property string direction
    property bool autoRun: true
    property ReminderWithTimer reminder

    QtObject { id: myOwn
        function getDirection(reminder) {
            switch (direction) {
            case "left": return reminder.enumDirection.left;
            case "right": return reminder.enumDirection.right;
            case "up": return reminder.enumDirection.up;
            case "down": return reminder.enumDirection.down;
            }
            return reminder.enumDirection.right
        }

        // TODO: make reminder local
        function remindDragToRight() {
            if(reminder!=null) return;
            var prop = {
                reminderType: UserSettings.remindTypeDragToExit,
                remindCancelOption: remindCancelOption,
                reminderDuration: reminderDuration,
            }
            var text = qsTr("Drag right to go back.")
            reminder = Create.instantComponent(hmouse.parent, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
            reminder.fontSize = UserSettings.fontPointSize
            reminder.cycleEndCallback = reminderEnd
            reminder.visible = parent.parent.visible
            reminder.showReminder(text, getDirection(reminder))
            reminder.noRemindClicked.connect(noRemindClicked)
        }

        function reminderEnd() {
            reminder.destroy();
            reminder = null //(function(){return ;})()
        }

        function noRemindClicked(type){
            UserSettings.dragToExitRemind = false
        }

        function invokeHint() {
            if(stackView.depth != 1 && hmouse.parent.x == 0
               && autoRun) {
                hint()
            }
        }
    }
    function hint() {
        if(UserSettings.dragToExitRemind) myOwn.remindDragToRight()
    }

    onVisibleChanged: {
        if (visible==false && typeof(reminder)!="undefined" && reminder !== null) {
            reminder.end();
        }
    }

    Component.onCompleted: stackView.onCurrentItemChanged.connect(myOwn.invokeHint)
    Component.onDestruction: stackView.onCurrentItemChanged.disconnect(myOwn.invokeHint)
}

