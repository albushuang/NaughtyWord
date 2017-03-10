import QtQuick 2.5

Flickable { id: scroll
    property alias text: editor.text
    property alias readOnly: editor.readOnly
    property alias font: editor.font
    property bool myFocus
    property alias color: editor.color
    property var selectAll: editor.selectAll
    property var deselect: editor.deselect
    property var forceActiveFocus: editor.forceActiveFocus

    contentHeight: editor.height
    contentWidth: editor.width
    TextEdit { id: editor
        anchors {top: parent.top; left: parent.left }
        width: scroll.width; height: contentHeight
        cursorVisible: !readOnly
        selectByMouse: !readOnly
        wrapMode: Text.WordWrap
        onCursorRectangleChanged: own.getCursorAndScroll(cursorRectangle);
        focus: scroll.myFocus
    }

    function moveY(offset) {
        scroll.contentY += offset
        if(scroll.contentY < 0) scroll.contentY = 0;
        if(scroll.contentY+scroll.height > scroll.contentHeight) {
            scroll.contentY = scroll.contentHeight-scroll.height;
        }
    }
    function scroll(y) {
        flick(0, y*15);
        flicking.start()
    }

    Timer { id: flicking
        triggeredOnStart: false
        interval: 400
        onTriggered: cancelFlick()
    }

    onContentYChanged: {
        if ( (contentY > 0 && editor.contentHeight < scroll.height)  || contentY < 0) {
            contentY = 0.0
        } else if(contentY+scroll.height > editor.contentHeight && contentY>0 ) {
            contentY = editor.contentHeight-scroll.height
        }
    }

    QtObject { id: own
        property int target
        function getCursorAndScroll(rect) {
            if (rect.y+rect.height>scroll.contentY+scroll.height) {
                contentY=rect.y+rect.height-scroll.height
            } else if (rect.y<scroll.contentY) {
                scroll.contentY = rect.y
            }
        }
    }
}
