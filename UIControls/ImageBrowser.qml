import QtQuick 2.0
import QtQuick.Controls 1.3


// delegations:
// imageBrowserSwipeFromLeft, imageBrowserSwipeFromRight
// imageBrowserBtnLeftClicked, imageBrowserBtnRightClicked
Rectangle { id: imageArea;
    property var delegator
    property string selectedColor: "transparent"
    property alias imageGrid: imageGrid
    property alias leftImage: btnLeftImage.source
    property alias rightImage: btnRightImage.source
    readonly property string urlField: "url"
    readonly property string agentField: "agentUrl"
    readonly property string tbUrlField: "tbUrl"


    signal imageBrowserClicked()
    width: 300; height: 250

    Component { id: imageCell
        Rectangle { width: imageGrid.cellWidth; height:imageGrid.cellHeight;
            color : GridView.isCurrentItem ? selectedColor : "transparent"
            property variant point: [0,0];

            Image { id: imageItemThumbNail
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: tbUrl
                BusyIndicator { id: busyIndicator; anchors.centerIn: parent }
                onProgressChanged: { busyIndicator.running = progress != 1 }
                visible: imageItemFullResolution.progress != 1
            }

            ProgressBar{ id: theBar
                value: imageItemFullResolution.progress
                anchors{bottom: imageItemThumbNail.bottom; bottomMargin: 3;
                    horizontalCenter: imageItemThumbNail.horizontalCenter}
                visible : (imageItemFullResolution.status!=Image.Ready &&
                                  displayAgent.status!=Image.Ready)
            }

            Image { id: imageItemFullResolution
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: url
                visible: progress==1
                cache: true
                onStatusChanged: {
                    if (status==Image.Error) {
                        delegator.imageBrowserNeedAgent(source, index);
                        displayAgent.visible = true;
                        imageItemFullResolution.visible = false;
                    }
                }
            }
            Image { id: displayAgent
                anchors.fill: parent
                visible: true
                fillMode: Image.PreserveAspectFit
                source: agentUrl
                cache: false
                onStatusChanged: {

                }
            }

            MouseArea { anchors.fill: parent;
                onPressed: { point[0] = mouse.x; point[1] = mouse.y; }
                onReleased: {
                    if (mouse.x > point[0] && Math.abs(point[0]-mouse.x) > 20) {
                        imageGrid.moveCurrentIndexLeft();
                        delegator.imageBrowserSwipeFromLeft();
                    } else if (point[0] > mouse.x && Math.abs(point[0]-mouse.x) > 20) {
                        imageGrid.moveCurrentIndexRight();
                        delegator.imageBrowserSwipeFromRight();
                    }else{  //Just tap
                        imageBrowserClicked()
                    }
                }
            }
        }
    }

    GridView { id: imageGrid;
        anchors {top: parent.top }
        cellWidth: parent.width; cellHeight: parent.height;
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        snapMode: GridView.NoSnap;
        flow: GridView.FlowTopToBottom;
        highlightRangeMode: GridView.StrictlyEnforceRange
        delegate: imageCell
        cacheBuffer: typeof(model) == "undefined" ? 0 : cellHeight * Math.max(0,(model.count-1))
        onCurrentIndexChanged: {
            if(currentIndex<=0) { btnLeftImage.opacity=0.2; }
            else { btnLeftImage.opacity=1; }
        }
    }

    Item { id: btnLeft;
        property alias image: btnLeftImage
        anchors { left: parent.left; leftMargin: 3; verticalCenter: parent.verticalCenter }
        width: parent.width*0.07; height: parent.height
        AutoImage { id: btnLeftImage; width: parent.width; height: rawHeight*width/rawWidth;
            anchors.centerIn: parent; }
        MouseArea { anchors.fill: parent;
            onClicked: {
                imageGrid.moveCurrentIndexLeft();
                delegator.imageBrowserBtnLeftClicked(btnLeft, mouse);
            }
            onPressAndHold: {
                imageGrid.currentIndex=0;
            }
        }
    }
    Item { id: btnRight;
        property alias image: btnRightImage
        width: parent.width*0.07; height: parent.height
        anchors { right: parent.right; rightMargin:3; verticalCenter: parent.verticalCenter }
        AutoImage { id: btnRightImage; width: parent.width; height: rawHeight*width/rawWidth;
            anchors.centerIn: parent; }
        MouseArea { anchors.fill: parent;
            onClicked: {
                imageGrid.moveCurrentIndexRight();
                delegator.imageBrowserBtnRightClicked(btnRight, mouse);
            }
        }
    }
    clip: true;

    function enableBrowsing(enable) {
        btnLeft.visible=enable;
        btnRight.visible=enable;
    }

    function setModel(model) {
        imageGrid.model = model;
    }

    function isLastImage() {
        return imageGrid.currentIndex == imageGrid.count-1;
    }

    function getCurrentIndex() {
        return imageGrid.currentIndex;
    }

    function imageElement(tbUrl, url, agentUrl) {
        this.tbUrl = tbUrl;
        this.url = url;
        this.agentUrl = agentUrl;
    }

    function updateIndex() {
        while(imageGrid.model.count != 0 && imageGrid.currentIndex<0) {
            imageGrid.moveCurrentIndexRight();
        }
    }
}
