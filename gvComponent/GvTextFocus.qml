import QtQuick 2.0

Item { id: root
    property alias imgSource: idImage.source
    property alias text: idText.text
    property alias color: idText.color
    property alias fontPointSize: idText.font.pointSize
    property alias periodIn: own.periodIn
    property alias periodOut: own.periodOut
    property alias periodStay: own.periodStay
    property Item star    // height must be bound to its width

    function start() {
        idImage.visible = true
        idText.visible = true
        own.request = 3
        own.initText(own.getPosition())
        own.setXY()
        own.initImage(0)
        imageAni.start()
        textAni.start()
        focusAni.start()
    }

    NumberAnimation { id: imageAni
        target: idImage
        property: "x"
        onStopped: {
            if(own.request%2==1) {
                own.request--
                own.imageOut()
            } else {
                idImage.visible = false
                //if(star != null) { star.visible = false }
                star.visible = false
            }
        }
    }
    NumberAnimation { id: textAni
        target: idText
        property: "x"
        onStopped: {
            if(own.request>=2) {
                own.request -= 2
                own.textOut()
            } else { idText.visible = false; star.visible = false }
        }
    }

    NumberAnimation { id: focusAni
        easing.type: Easing.InQuint
        target: star
        property: "width"
    }

    Image { id: idImage
        height: parent.height
        width: parent.width
        x: parent.width
        visible: false
    }

    Text { id: idText
        font.pointSize: 20
        fontSizeMode: Text.VerticalFit
        verticalAlignment: Text.AlignVCenter
        height: parent.height*0.8
        x: -contentWidth
        y: parent.height/2-contentHeight/2
        color: "red"
        visible: false
    }


    QtObject { id: own
        property int request
        property int periodIn: 1000
        property int periodOut: 500
        property int periodStay: 800

        function initText(target) {
            textAni.easing.type = Easing.OutQuint
            textAni.duration = periodIn
            textAni.to = target
        }
        function initImage(target) {
            imageAni.easing.type = Easing.OutQuint
            imageAni.duration = periodIn
            imageAni.to = target
        }
        function setXY() {
            idText.y = 0
            idText.x = -idText.contentWidth
            idImage.x = parent.width
            idImage.y = 0
            if(star != null) {
                star.visible = true
                star.anchors.leftMargin = 10
                star.anchors.left = Qt.binding(function() { return idText.right })
                star.visible = true
                focusAni.to = star.width
                star.width = star.width*5
            }
        }
        function imageOut() {
            initImage(root.width)
            imageAni.easing.type = Easing.InBack
            imageAni.duration = periodOut
            imageAni.start()
        }
        function textOut() {
            initText(-idText.contentWidth+10+star.width)
            textAni.easing.type = Easing.InBack
            textAni.duration = periodOut
            textAni.start()
        }
        function getPosition(){
            var starWidth = 0
            var border = 10
            if (star!=null) { starWidth = star.width }
            return root.width/2-(idText.contentWidth+starWidth+border)/2
        }
    }
}

