import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle { id: whole
    property alias accuracy: imgAccuracy.text
    color: "white"
    opacity: 0.5
    width: parent.width
    height: parent.height/3
    anchors {
        left: parent.left
        top: parent.top; topMargin: 55
    }
    MouseArea {
        anchors.fill: parent
        onDoubleClicked: {
            if(whole.height!=50) { whole.height = 50 }
            else { whole.height = whole.parent.height/3 }
        }
    }
    Rectangle { id: b1
        anchors { left: parent.left; top: parent.top; }
        width: parent.width*0.8; height: parent.height/2
        TextEdit { id: dummyWord; anchors.fill: parent
            color: "blue"
            font.pointSize: 20
            clip: true
        }
        color: "yellow"
    }
    Rectangle {
        anchors { left: parent.left; top: b1.bottom; }
        width: parent.width*0.8; height: parent.height/2
        TextEdit { id: dummyNote; anchors.fill: parent
            color: "blue"
            font.pointSize: 20
            clip: true
        }
        color: "pink"
    }
    Rectangle {
        anchors { right: parent.right; top: parent.top; }
        width: parent.width*0.2; height: parent.height/2
        TextEdit { id: imgAccuracy; anchors.fill: parent
            color: "blue"
            font.pointSize: 20
            clip: true
        }
        color: "green"
    }

    function getWord() {
        return dummyWord.text
    }
    function getNote() {
        return dummyNote.text
    }
    function setWord(word) {
        dummyWord.text = word
    }
    function setNote(note) {
        dummyNote.text = note
    }
}
