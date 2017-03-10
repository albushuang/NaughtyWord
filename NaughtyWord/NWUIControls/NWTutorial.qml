import QtQuick 2.0
import "qrc:/../../UIControls"
import "qrc:/generalJS/tutorialScript.js" as TutScript

Tutorial {

    tutScript: TutScript
    txtAutoPositioning: false
    textBorderFrame.visible: false
    imageRatio: 0.7
    indicator: finger
    AutoImage { id: finger
        source: "qrc:/pic/alient finger02.png"
        visible: false
        z: 100
    }

    Component.onCompleted: {
        gText.width = Qt.binding(function(){return gImage.width*272/406})
        gText.height = Qt.binding(function(){return gImage.height*272/572})
        gText.x = Qt.binding(function(){return gImage.x + gImage.width*71/406})
        gText.y = Qt.binding(function(){return gImage.y + gImage.height*238/572})
        gText.color = "white"
        gText.z = 3
    }

    function resetTutorial(){
        tutorialKey = ""
        focusItem = null//(function () { return; })(); //assign undefined in a safe way
        focusBtn = null//(function () { return; })();
        imgAutoPositioning = true
        imageRatio = 0.7
        foggyEffect = true
        focusFrameEnabled = true
    }
}

