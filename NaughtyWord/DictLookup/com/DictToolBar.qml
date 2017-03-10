import QtQuick 2.5
//import "./ToolBar.qml"

ToolBar { id: toolBar
    property alias audioBar: audioBar
    property Item content1
    property Item content2
    property Item contentp

    AudioBar { id: audioBar
        hRatio: toolBar.hRatio
        vRatio: toolBar.vRatio
        asynchronous: toolBar.asynchronous
        anchors { bottom: parent.bottom;
            left: button2.right; leftMargin: 18*hRatio;
        }
        onWidthChanged: { if(width>100 && vRatio>0) formatContent() }
    }

    function formatContent() {
        if(content1==null) return
        content1.parent = button1
        content1.anchors.centerIn = toolBar.button1
        content1.width = 60*hRatio
        content1.height = 60*vRatio

        content2.parent = button2
        content2.anchors.centerIn = toolBar.button2
        content2.width = 60*hRatio
        content2.height = 60*vRatio

        contentp.parent = audioBar
        contentp.width = 60*hRatio
        contentp.height = 60*vRatio
        contentp.anchors.left = audioBar.left
        contentp.anchors.leftMargin = 45*audioBar.width/659
        contentp.anchors.verticalCenter = audioBar.verticalCenter
    }

}
