import QtQuick 2.0
import QtMultimedia 5.5
import "qrc:/DictLookup/com"
import com.glovisdom.UserSettings 0.1

Image { id: ankiview
    property alias cardModel: fieldsView.model
    property var delegator
    source: "qrc:/pic/background0.png"
    Component { id: oneField
        Image {
            source: "qrc:/dictView_blueFrame2.png"
            width: fieldsView.width
            height: {
                var v1 = fieldName.height + 6 + 6 + 6
                v1 += content.contentHeight>content.height ? content.contentHeight : content.height
                return v1
            }
            Text { id: fieldName
                anchors { left: parent.left; leftMargin: 6; top: parent.top; topMargin:6 }
                text: name
                height: 25
                font.pointSize: UserSettings.fontPointSize-2
                font.bold: true
                width: fieldsView.width
                wrapMode: Text.WordWrap
                color: "white"
            }
            Text { id: content
                property Image img
                anchors { top: fieldName.bottom; topMargin:6; leftMargin: 6; left: parent.left }
                height: 20
                font.pointSize: UserSettings.fontPointSize
                width: fieldsView.width
                wrapMode: Text.WordWrap
                color: "white"
                Component.onCompleted: {
                    imageFilter(content, fieldContent);
                }
                Component.onDestruction: {
                    if(img!=null) { img.destroy() }
                }
            }
            Image {
                source: "qrc:/SpeakerOn.png"
                width: 30; height:30
                anchors { bottom: parent.bottom; bottomMargin: 6; right: parent.right; rightMargin:6 }
                Audio { id: speech
                    source: audioSource
                    autoPlay: false
                    autoLoad: false
                }
                visible: speech.source!=""
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        delegator.speechClicked(speech, index)
                    }
                }
                Component.onCompleted: {
                    if (autoAudio && fieldsView.show) {
                        fieldsView.show = false
                        delegator.speechClicked(speech, index)
                    }
                }
            }
        }
    }

    function imageFilter(textObj, content) {
        var obj = {}
        getContentAndImage(content, obj);
        textObj.text = obj.text
        if(obj.image!="") {
            var qml = '
                import QtQuick 2.3
                Image { anchors {bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width: parent.width*0.8; height: width*sourceSize.height/sourceSize.width
                    source:"'+obj.image+'"}'
            textObj.img = Qt.createQmlObject(qml, textObj);
            textObj.height += textObj.img.height
        }
    }
    function getContentAndImage(content, obj) {
        var index = content.indexOf("<img src=")
        if (index<0) { obj.text = content; obj.image = ""; return }
        var quote = content[index+9]
        var index2 = content.indexOf(">")
        var replace = content.substring(index, index2+1)
        obj.text = content.replace(replace, "")
        index = replace.indexOf(quote)
        index2 = replace.indexOf(quote, index+1)
        obj.image = replace.substring(index+1, index2)
    }

    ListView { id: fieldsView
        property bool show: true
        anchors { horizontalCenter: ankiview.horizontalCenter }
        delegate: oneField
        width: parent.width*0.8
        height: parent.height-underBar.height-15-8
        spacing: 10
        clip: true
        onModelChanged: { model.onCountChanged.connect(newItems) }
        function newItems() {
            if(count==0)show = true;
        }
    }
    function moveY(offset) {
        fieldsView.contentY += offset
        if(fieldsView.contentY < 0) fieldsView.contentY = 0;
        if(fieldsView.contentY+fieldsView.height > fieldsView.contentHeight && fieldsView.contentHeight>fieldsView.height) {
            fieldsView.contentY = fieldsView.contentHeight-fieldsView.height;
        }
    }
    function flickIt(y) {
        fieldsView.flick(0, y*15);
        flicking.start()
    }

    Timer { id: flicking
        triggeredOnStart: false
        interval: 400
        onTriggered: fieldsView.cancelFlick()
    }

    Image { id: underBar
        source: "qrc:/pic/NW_GamePage_Orange option.png"
        anchors {bottom: parent.bottom; bottomMargin: 15; left: parent.left}
        width: parent.width; height: 100*parent.height/1334
        ImgButton {
            height: parent.height*0.8
            anchors { right: parent.right; rightMargin: 24*parent.width/750; verticalCenter: parent.verticalCenter }
            callAtClicked: delegator.viewUnload
            source: "qrc:/pic/dictView_iconClose.png"
        }
    }

    function modelElement(name, content, audio, auto) {
        this.name = name
        this.fieldContent = content
        this.audioSource = audio
        this.autoAudio = auto
    }
}
