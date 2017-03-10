import QtQuick 2.0

//  Flickable { id: itemPack}
/*a flickable inside listview can works only for mouse sroll. It doesn't work for
mobile swipe*/
Item { id: itemPack
    property alias text: thisText.text
    property alias color: thisText.color
    property alias font: thisText.font
    property alias textMouse: textMouse
    property alias textObj: thisText    /*This Obj is opened only in case that user wants to access some other properties*/

    Text{ id: thisText;
        height: itemPack.height
        x: contentWidth<=itemPack.width?(itemPack.width-contentWidth)/2 : 0;
        y: (itemPack.height-height)/2
        fontSizeMode: Text.VerticalFit
        horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
    }
    clip: true
    MouseArea{id: textMouse
        anchors.fill: parent;
        drag.target:thisText
        drag.axis: Drag.XAxis
        drag.minimumX: -(thisText.contentWidth - itemPack.width)
        drag.maximumX: 0;
        drag.filterChildren: true
        drag.threshold: thisText.contentWidth < itemPack.width ? 9999 : 0
    }
}


