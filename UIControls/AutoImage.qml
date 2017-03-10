import QtQuick 2.0
import QtQuick.Controls 1.2

Image {
//Please set "autoCalculateSize" = false if you use anchors to set width&height
    property bool autoCalculateSize: true   //[Optional]
    property real fullWidth: 1242   //[Optional]
    property real fullHeight: 2208
    //Shadow gives us svg images under 750/1334 condition. But we want to change svg to png in order to
    // incread loading speed. So we convert svg to png in 1242/2208 (iphone 6 plus) condition
    property real widthRatio: stackView.width/fullWidth
    property real heightRatio: stackView.height/fullHeight
    property real rawWidth
    property real rawHeight
    width: autoCalculateSize ? widthRatio*rawWidth : 0;
    height: autoCalculateSize ? heightRatio*rawHeight : 0

    property bool newSource: true
    property string sourceStr: source.toString()
    onStatusChanged: {
//When the image is loaded, we can save raw image size from sourceSize.
//Then, we want to bind sourceSize to width/height. So we can display clear image
//when the width/height is large
        if(sourceStr.indexOf("gameSelect_yellowFrame.svg") != -1){
            console.log("sourceStr", sourceStr,"status:", status)
        }

        if(newSource && status == Image.Ready  && sourceStr.indexOf(".svg") != -1){
//            console.log("image loaded")
            newSource = false   //Do following code only once, if source is changed
            rawWidth = sourceSize.width    //Setting value only, this will not trigger property binding
            rawHeight = sourceSize.height
            sourceSize.width = Qt.binding(function (){return this.width;})
            sourceSize.height = Qt.binding(function (){return this.height;})

        }else if(sourceStr.indexOf(".png") != -1){  //In PNG's case, imgae loading will be only executed once
            newSource = false
            rawWidth = sourceSize.width    //Setting value only, this will not trigger property binding
            rawHeight = sourceSize.height
        }
    }

    onSourceChanged: {
        if(sourceStr != "") {
            sourceSize = (function(){return ;})()   //unbind from width/height
            newSource = true
        }
    }

}

