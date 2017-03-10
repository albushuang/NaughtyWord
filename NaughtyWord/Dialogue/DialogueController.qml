import QtQuick 2.0

Item { id: controller;
    property var callback
    property string title
    property bool hasTwoBtns : true
    property bool hasInput: true

    anchors.centerIn: parent
    Dialogue { id: view
        title: controller.title
        hasTwoBtn: controller.hasTwoBtns
        hasInput: controller.hasInput
        anchors.fill: parent
        onConfirmed: {
            //thisObj,  action,  userInput
            callback(userInput);
        }
        onCancelled: { }
    }
    function show(title, callbackfuntion) {
        view.show(title);
        callback = callbackfuntion
    }
    function setInputText(text) {
        view.setInputText(text);
    }
}
