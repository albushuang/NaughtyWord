import QtQuick 2.4
import QtQuick.Controls 1.3

Item { id: control
    property bool hasTwoBtns : true
    property bool hasInput: true
    property var callback
    property var cancelCB
    property string title
    property bool disableBackgroundMouse: true
    signal backgroundClicked()
    visible: false

    Item{id: mouseStealer; visible: disableBackgroundMouse
        width: control.parent.width; height: control.parent.height
        x: -control.x; y: -control.y  //Cannot anchors.fill: dialog.parent
        MouseArea{ anchors.fill: parent;
            onClicked: {
                textInputFocusOff()
                backgroundClicked()}
        }
    }

    function textInputFocusOff(){
        if(hasInput)
            view.textInput.focus = false
    }

    anchors.centerIn: parent
    NWDialog { id: view
        width: parent.width
        delegator: own
        state: "inputAndTwoButtons"
        visible: control.visible
        title: control.title
    }

    onHasInputChanged: {
        own.setType();
    }
    onHasTwoBtnsChanged: {
        own.setType();
    }

    QtObject { id: own
        function setType() {
            if (hasTwoBtns && hasInput) {
                view.state = "inputAndTwoButtons"
            } else if (hasTwoBtns && !hasInput) {
                view.state = "onlyTwoButtons"
            } else if (!hasTwoBtns) {
                view.state = "singleConfirm"
            }
        }
        function yesClicked(text) {
            textInputFocusOff()
            visible = false;
            if(hasInput){ callback(text)}
            else{ callback()}
        }

        function noClicked(text) {
            textInputFocusOff()
            visible = false;
            if(typeof(cancelCB) != "undefined"){
                cancelCB(text)
            }
        }
    }

    function show(message, callbackfuntion) {
        view.message = message;
        visible = true;
        if(hasInput){
            view.textInput.focus = false
            view.textInput.forceActiveFocus();
        }
        if(typeof(callbackfuntion)!="undefined") { callback = callbackfuntion }
    }
    function setInputText(text) {
        view.setInputText(text);
    }
}
