import QtQuick 2.5
import "qrc:/../../UIControls"

AutoImage { id: speech
    property alias model: speechListView.model
    property AutoImage currentImage
    property real hRatio
    property real vRatio
    property var callAtClicked

    Component { id: speechIcons
        Item {
            width: 91*hRatio; height: 75*vRatio
            ImgButton { id: button
                anchors { bottom: parent.bottom;
                left: parent.left; }
                source: image
                callAtClicked: function () {
                    own.speechClicked(index);
                }
            }
        }
    }
    ListView { id: speechListView
        anchors { top: parent.top; topMargin: 10*vRatio
            left: parent.left; leftMargin: 114*hRatio;
            bottom: parent.bottom
            right: parent.right
        }
        delegate: speechIcons
        orientation: ListView.Horizontal
        onCurrentItemChanged: {
            if(currentIndex!=-1) {
                currentImage.parent = currentItem
                currentImage.anchors.bottom = currentItem.bottom
                currentImage.anchors.left = currentItem.left
            }
        }
    }
    function getSpeechElement(url, source) {
        this.url = url
        this.image = source
    }
    function getCurrentIndex() {
        return speechListView.currentIndex
    }
    QtObject { id: own
        function speechClicked(index) {
            speechListView.currentIndex=index;
            speech.callAtClicked(index)
        }
    }
}
