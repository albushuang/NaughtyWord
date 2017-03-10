import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1

GridView { id: fileShow
    property int spacing: 3
    property int columns: 1
    property int iconSize: 30
    property int fontSize: 20
    property int animationDuration: 200
    property int prevIndex;
    property string iconSource;
    property alias folderModel: folderModel
    property alias filters: folderModel.nameFilters
    property alias showDirs: folderModel.showDirs
    property alias folder: folderModel.folder

    cellWidth: width/columns; cellHeight: iconSize*2+spacing*2

    FolderListModel { id: folderModel
        nameFilters: [ "*.kmrj" ]
        showDirs: false
        onFolderChanged: {
            newFolderRequest();
        }
    }
    Component { id: fileDelegate
        Rectangle { id: rect
            width: fileShow.cellWidth; height: fileShow.cellHeight;
            Image { id: theIcon; source: iconSource;
                fillMode: Image.PreserveAspectFit;
                anchors { horizontalCenter: parent.horizontalCenter; top: rect.top; topMargin: spacing }
                width: parent.height*0.5; height: parent.height*0.5
            }
            Text { id: nameText; text: fileName.slice(0,fileName.length-5); width: fileShow.cellWidth-spacing*2
                anchors { horizontalCenter: rect.horizontalCenter; top: theIcon.bottom; topMargin:spacing}
                horizontalAlignment: Text.AlignHCenter;
                wrapMode: Text.WordWrap;
                font.pixelSize: fontSize
            }
            MouseArea { anchors.fill: parent
                onClicked: {
                    itemClicked(index, fileName);
                }
            }
            color: "transparent"
        }
    }

    highlight: Rectangle { color: "#F2F2F2"; radius: 5 }
    highlightFollowsCurrentItem : true; keyNavigationWraps : true
    highlightMoveDuration: animationDuration

    model: folderModel
    delegate: fileDelegate
    clip: true

    function newFolderRequest() { }

    function itemClicked(index, fileName) { }
}
