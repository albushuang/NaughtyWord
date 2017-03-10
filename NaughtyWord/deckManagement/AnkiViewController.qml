import QtQuick 2.0
import QtQuick.Controls 1.4
import QtMultimedia 5.5
import AnkiPackage 0.1
import AudioWorkaround 0.1
import "qrc:/../../UIControls"

Item { id: controller;
    property string path
    property int cardIndex: 0
    property string cardID
    property var models

    AnkiPackage { id: anki }

    AnkiView { id: view
        cardModel: ankiData
        anchors.fill: parent
        delegator: own
    }

    BrowseControl { id: browseControl
        delegator: own
        lImgUrl: "qrc:/pic/dictView_arrowLeft.png"
        rImgUrl: "qrc:/pic/dictView_arrowRight.png"
        dragTarget: controller
        dragExit: false
        property int px
        property int py
        property int dy
        onMpressed: { px = x; py = y }
        onYMoved: { view.moveY(py-y); dy = y-py; py=y }
        onMreleased: {
            if (Math.abs(dy)>15) { view.flickIt(dy*4) }
        }
    }

    QtObject { id: own
        function clickedOnLeftBtn() {
            cardIndex--
            if(cardIndex<0) cardIndex=0
            workAround.releaseResource(cardID)
            fillModel(anki.browse(cardIndex))
        }
        function clickedOnRightBtn() {
            cardIndex++
            workAround.releaseResource(cardID)
            fillModel(anki.browse(cardIndex))
        }
        function clickedOnUpBtn() { }
        function clickedOnDownBtn() { }

        function speechClicked(audio, index) {
            audio.play()
        }
        function viewUnload() {
            stackView.pop()
        }
    }

    ListModel { id: ankiData }
    AudioWorkaround { id: workAround }

    Component.onCompleted: {
        anki.openPackage(path)
        models = anki.models
        fillModel(anki.browse(cardIndex))
    }
    function fillModel(card) {
        ankiData.clear()
        cardID = card[models.length];
        var flag=false
        for (var i=0;i<models.length;i++) {
            var sUrl = getAudio(card[i])
            var element = new view.modelElement(models[i].name,
                                                removeSoundNote(getImage(card[i])),
                                                sUrl, (sUrl!="" && flag==false))
            if(sUrl!="" && flag==false) flag = true
            ankiData.append(element)
        }
    }
    function getAudio(content) {
        var res = workAround.makeResource(cardID, content, path)
        if (res.length==0) return ""
        else { return "file://" + res[0] }
    }
    function getImage(content) {
        var index = content.indexOf("<img src=")
        if (index<0) return content
        var quote = content[index+9]
        var ret = content.substr(index+10)
        index = ret.indexOf(quote)
        if (index<0) return content
        var target = ret.substr(0, index);
        var newContent = "file://"+path+"/"+target.split("##")[1]
        return content.replace(target, newContent)
    }
    function removeSoundNote(content) {
        var str = content
        do {
            var h = str.indexOf("[sound:")
            if(h<0) break;
            var e = str.indexOf("]", h)
            str = str.substring(0,h) + str.substring(e+1)
        } while(1)
        return str
    }
}
