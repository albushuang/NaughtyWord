import QtQuick 2.0
import QtQuick.Controls 1.3


// delegations:
// imageBrowserSwipeFromLeft, imageBrowserSwipeFromRight
// imageBrowserBtnLeftClicked, imageBrowserBtnRightClicked
Rectangle { id: imageArea;
    property var delegator
    property alias imageGrid: imageGrid
    property alias leftImage: btnLeftImage.source
    property alias rightImage: btnRightImage.source
    property bool enableCrop: false
    property bool enableWheel: true
    readonly property string urlField: "url"
    readonly property string agentField: "agentUrl"
    readonly property string tbUrlField: "tbUrl"
    property var thumbnail
    property alias model: imageGrid.model

    signal imageBrowserClicked()
    width: 300; height: 250

    Component { id: imageCell
        Rectangle { id: container
            width: imageGrid.width; height:imageGrid.height;
            color : "transparent"
            property string observer: ListView.isCurrentItem ? "current" : "other"
            property variant point: [0,0];

            Image { id: imageItemThumbNail
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: tbUrl
                BusyIndicator { id: busyIndicator; anchors.centerIn: parent }
                onProgressChanged: { busyIndicator.running = progress != 1 }
                onStatusChanged: {
                    if(status==Image.Ready && container.observer=="current") {
                        own.anchorCropRect(container, imageItemThumbNail);
                    }
                    if (status==Image.Error) {
                        delegator.tbError(imageItemThumbNail);
                    }
                }
                onPaintedWidthChanged:  {
                    if(status==Image.Ready && container.observer=="current") {
                        //console.log("pwc,", imageGrid.currentIndex, index)
                        if(paintedWidth!=0) imageGrid.currentIndex = index
                        own.anchorCropRect(container, imageItemThumbNail);
                    }
                }
                onPaintedHeightChanged: {
                    if(status==Image.Ready && container.observer=="current") {
                        //console.log("phc,", imageGrid.currentIndex, index)
                        if(paintedHeight!=0) imageGrid.currentIndex = index
                        own.anchorCropRect(container, imageItemThumbNail);
                    }
                }
                cache: false
            }

            onObserverChanged: {
                if(ListView.isCurrentItem) {
                    //console.log("obc,", imageGrid.currentIndex, index)
                    thumbnail = imageItemThumbNail
                    displayAgent.parent = container
                    displayAgent.source = ""
                    displayAgent.tbImage = imageItemThumbNail
                    delegator.imageBrowserNeedAgent(url, index)
                    displayAgent.anchors.fill = container
                    own.anchorCropRect(container, imageItemThumbNail);
                }
            }

        }
    }

    Image { id: displayAgent
        property var tbImage
        fillMode: Image.PreserveAspectFit
        cache: false
        visible: (sourceSize.width != 0)
        onStatusChanged: {
            if(status==Image.Ready) {
                tbImage.source = source
            }
        }
    }

    ListView { id: imageGrid;
        width: parent.width; height: parent.height
        anchors {top: parent.top }
        snapMode: ListView.SnapOneItem;
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        delegate: imageCell
        cacheBuffer: typeof(model) == "undefined" ? 0 : height * Math.max(0,(model.count-1))
        onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Contain);
            if(currentIndex<=0) { btnLeftImage.opacity=0.2; }
            else { btnLeftImage.opacity=1; }
        }
        onFlickStarted: {
            if(horizontalVelocity<0) {
                delegator.imageBrowserSwipeFromLeft();
            } else if(horizontalVelocity>0) {
                delegator.imageBrowserSwipeFromRight();
            }
        }
        MouseArea {
            enabled: enableWheel
            property int startPixel : 0
            anchors.fill: parent
            onWheel: {
                if(startPixel == 0) {startPixel = wheel.pixelDelta.x }
                else if(wheel.pixelDelta.x == 0) {
                    if(startPixel>0) { delegator.imageBrowserSwipeFromLeft();}
                    else if(startPixel<0) { delegator.imageBrowserSwipeFromRight(); }
                    startPixel = 0
                }
                wheel.accepted = false;
            }
            onClicked: {imageBrowserClicked()}
        }
        property int heightIndex
        property bool sizeChanged: false
        onHeightChanged: {
            //console.log("height changed", currentIndex)
            heightIndex = currentIndex
            sizeChanged = true
            positionViewAtIndex(currentIndex, ListView.SnapPosition)
        }
        onCurrentItemChanged: {
            //console.log("item changed", currentIndex)
            if(sizeChanged) {
                sizeChanged = false
                currentIndex = heightIndex
                positionViewAtIndex(currentIndex, ListView.SnapPosition)
            }
        }
    }

//    ProgressBar{ id: theBar
//        value: imageItemFullResolution.progress
//        anchors{bottom: imageGrid.bottom; bottomMargin: 3;
//            horizontalCenter: imageGrid.horizontalCenter}
//        visible : (imageItemFullResolution.status!=Image.Ready &&
//                          displayAgent.status!=Image.Ready && imageItemFullResolution.source !="")
//    }

    CropFrame2 { id: cropRect
        visible: enableCrop //&& (displayAgent.status==Image.Ready)
        square: false
    }

    QtObject { id: own
        property int paintedWidth
        property int paintedHeight
        function anchorCropRect(frame, image) {
            paintedWidth = image.paintedWidth
            paintedHeight = image.paintedHeight
            cropRect.width = image.paintedWidth>image.paintedHeight?
                        image.paintedHeight: image.paintedWidth
            cropRect.height = cropRect.width
            cropRect.x = image.x + (image.width-cropRect.width)/2
            cropRect.y = image.y + (image.height-cropRect.height)/2
            cropRect.z = 99;
            cropRect.minX = (image.width-paintedWidth)/2
            cropRect.maxX = (image.width+paintedWidth)/2
            cropRect.minY = (image.height-paintedHeight)/2
            cropRect.maxY = (image.height+paintedHeight)/2
        }
    }


    Item { id: btnLeft;
        property alias image: btnLeftImage
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        width: parent.width*0.1; height: parent.height
        AutoImage { id: btnLeftImage; width: parent.width*0.7; height: rawHeight*width/rawWidth;
            anchors{ left: parent.left; leftMargin: 3*vRatio; verticalCenter: parent.verticalCenter} }
        MouseArea { anchors.fill: parent;
            onClicked: {
                imageGrid.decrementCurrentIndex();
                delegator.imageBrowserBtnLeftClicked(btnLeft, mouse);
            }
            onPressAndHold: {
                imageGrid.currentIndex=0;
            }
        }
    }

    Item { id: btnRight;
        property alias image: btnRightImage
        width: parent.width*0.1; height: parent.height
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        AutoImage { id: btnRightImage; width: parent.width*0.7; height: rawHeight*width/rawWidth;
            anchors{ right: parent.right; rightMargin: 3*vRatio; verticalCenter: parent.verticalCenter}}
        MouseArea { anchors.fill: parent;
            onClicked: {
                imageGrid.incrementCurrentIndex();
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
        return {tbUrl: tbUrl, url: url, agentUrl: agentUrl }
//        this.tbUrl = tbUrl;
//        this.url = url;
//        this.agentUrl = agentUrl;
    }

    function updateIndex() {
        while(imageGrid.model.count != 0 && imageGrid.currentIndex < 0) {
            imageGrid.incrementCurrentIndex();
        }
    }

    function resetIndex(){
        imageGrid.currentIndex = 0
        imageGrid.heightIndex = 0
    }

    function setAgentUrl(url, index) {
        if(imageGrid.currentIndex==index) {
            displayAgent.source = url;
        }
    }

    function reportCropInfo() {
        return [cropRect.x, cropRect.y,
                cropRect.width, cropRect.height,
                (imageGrid.width-own.paintedWidth)/2, (imageGrid.height-own.paintedHeight)/2,
                own.paintedWidth, own.paintedHeight];
    }
}
