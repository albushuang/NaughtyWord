import QtQuick 2.4
import QtQuick.Controls 1.2

// delegation functions:
//   twoClicksOnSuggestItem(index);
//   clickOnSuggestItem(index);
//   suggestContent(index);

Rectangle {
    property var delegator;
    property alias listView: listView
    property alias model: listView.model
    property alias animation: listView.animation
    property alias currentIndex: listView.currentIndex
    property alias currentItem: listView.currentItem
    property alias highlightItem: listView.highlightItem
    property string highlightBGColor: "lightsteelblue";
    property bool suggestionExist: false
//TODO use screen.pixel density. Otherwise, android's UI will be too small
    radius: 4
    height:{
        if(typeof(model) == "undefined"){ (function(){return})()}
        else{model.count < 4 ? (model.count*virtualText.height) : (4*virtualText.height)}
    }
    color: "lightblue"

    ListView { id: listView; clip: true; spacing: 2;
        anchors.fill: parent
        property bool animation: false;
//: Max: I don't think the following "test" should be translated.
        Text { id: virtualText; visible: false; font.pixelSize: iFontSize; text: "test" }
        delegate : Text {
            text: delegator.suggestContent(index);
            font.pixelSize: iFontSize
            MouseArea {
                anchors.fill: parent
                onClicked: clickOnItem(index);
                onDoubleClicked: delegator.twoClicksOnSuggestItem(index);
            }
            color: "black"
        }

        highlight: highlight
        highlightFollowsCurrentItem : true; keyNavigationWraps : true
        highlightResizeDuration: 200
        highlightMoveDuration: 200

        Component {
            id: highlight
            Rectangle { id: highlightBox; color: highlightBGColor; radius: 0 }
        }
    }

    function clickOnItem(index) {
        listView.currentIndex = index;
        delegator.clickOnSuggestItem(index);
    }
    onHeightChanged:
        if(model.count != 0) suggestionExist = true
        else suggestionExist = false
}





