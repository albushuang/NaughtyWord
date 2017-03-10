import QtQuick 2.5
import QtMultimedia 5.0
import "qrc:/../../UIControls"
import "qrc:/gvComponent"
import "./com"
import "../generalJS/generalConstants.js" as GeneralConsts
import com.glovisdom.UserSettings 0.1

// delegation function
//   for view
//     viewUnload
//   for textinput
//     inputReturned(userInput.text);
//     textChanged(text);
//     userClearInput();
//   for looked-up contents
//     updateDetails(details);
//     updateIndexUp(suggestion.currentIndex);
//     updateIndexDown(suggestion.currentIndex);
//   for suggestionWindow
//     twoClicksOnSuggestItem(index);
//     clickOnSuggestItem(index);
//     suggestContent(index);
//   for addCard
//     addCardClicked();
//   for speech
//     clickOnSpeech(audio, index)
//   for dictionary
//     dictBtnClicked();


Item { id: view
    property var delegator;
    property real hRatio: width/750
    property real vRatio: height/1334
    property alias suggestionModel: suggestion.model;
    property alias imageBrowser: imageBrowser   //alias following item for tutorial (focusItem)
    property alias searchOtherImage: searchOtherImage
    property alias addCardBtn: toolBar.button1
    property string addCard: qsTr("Add")
    property string updateCard: qsTr("Update")
    property string mainName
    property alias searchFrameY: frame.y
    property alias initialFrameY: frame.initialFrameY
    property alias suggestionFrameY: frame.suggestionFrameY

    property var directPicture
    property bool showDirectPic
    property alias userInput: userInput
    property alias otherKey: otherKey

    states: [
        State {
            name: "lookup"
            StateChangeScript {
                script: {
                    imageBrowser.enableCrop = true;
                    frame.visible = true
                    search.anchors.fill = searchFrameInit
                    resultPage.visible = false
                    userInput.inputText.readOnly = false;
                    mainName = addCard
                }
            }
        },
        State {
            name: "result"
            StateChangeScript {
                script: {
                    mainName = addCard
                    imageBrowser.enableCrop = true;
                    frame.visible = false
                    search.anchors.fill = searchFrameResult
                    resultPage.visible = true
                    toolBar.button1.state = "main"
                    userInput.inputText.readOnly = false;
                    dictionaryMenu.anchors.left = searchFrameResult.right;
                    dictionaryMenu.anchors.leftMargin = 10*vRatio
                    dictionaryMenu.anchors.verticalCenter = searchFrameResult.verticalCenter
                }
            }
        },
        State {
            name: "deck"
            StateChangeScript {
                script: {
                    mainName = updateCard
                    dictionaryMenu.visible = false;
                    frame.visible = false;
                    search.anchors.fill = searchFrameResult;
                    resultPage.visible = true
                    toolBar.button1.state = "sub"
                    userInput.readonly = true
                    detailText.readOnly = true
                    imageBrowser.enableCrop = false
                    imageBrowser.enableWheel = false
                }
            }
        },
        State {
            name: "deckUpdate"
            StateChangeScript {
                script: {
                    mainName = updateCard
                    dictionaryMenu.visible = false;
                    frame.visible = false;
                    search.anchors.fill = searchFrameResult;
                    resultPage.visible = true
                    toolBar.button1.state = "main"
                    userInput.readonly = true
                    detailText.readOnly = true
                    imageBrowser.enableCrop = true;
                    imageBrowser.enableWheel = true
                }
            }
        }
    ]
    property int barHeight: 50*vRatio;

    Image {
        source: "qrc:/pic/background0.png"
        anchors.fill: parent
    }

    Item { id: resultPage
        anchors.fill: parent
        visible: false
        AutoImage { id: detailArea
            asynchronous: true
            autoCalculateSize: false
            source: "qrc:/pic/dictView_background.png"
            anchors { left: parent.left; right: parent.right
                top: parent.top; topMargin: 95*vRatio
                bottom: parent.bottom; bottomMargin:82*vRatio
            }
        }
        AutoImage { id: searchBtn
            asynchronous: true
            source: "qrc:/pic/dictSearchSymbol.png"
            autoCalculateSize: false
            anchors { bottom: parent.bottom; bottomMargin: 3
                top: detailArea.bottom; topMargin: 3
                horizontalCenter: parent.horizontalCenter
            }
            width: 78*hRatio;
            MouseArea{anchors.fill: parent
                onClicked: {
                    userInput.inputText.selectAll()
                    userInput.inputText.focus = false
                    userInput.inputText.forceActiveFocus();
                    delegator.clickedOnSearchBtn();
                }
            }
        }

        ///// toolbar begins //////////////////////
        DictToolBar { id: toolBar
            hRatio: view.hRatio
            vRatio: view.vRatio
            anchors { bottom: detailArea.bottom; bottomMargin: 14*vRatio
                left: parent.left; }
            width: parent.width
            asynchronous: true
            button1.sources: ["qrc:/DictLookup/pic/iconYellow.png",
                              "qrc:/DictLookup/pic/iconRed.png"]
            button2.sources: ["qrc:/DictLookup/pic/iconDPurple.png",
                              "qrc:/DictLookup/pic/iconGreen.png"]
            button3.source: "qrc:/pic/dictView_iconClose.png"
            content2: IconText {text: toolBar.button2.state=="main" ? GeneralConsts.txtAbbrSynonym : GeneralConsts.txtAbbrDefinition}
            contentp: IconText {text: GeneralConsts.txtAbbrPronuciation }
            content1: Item {
                IconText { width: parent.width; height: parent.height/2; anchors {top: parent.top} text: toolBar.button1.state=="main" ? mainName : GeneralConsts.txtAbbrDelete}
                IconText { width: parent.width; height: parent.height/2; anchors {bottom: parent.bottom} text: qsTr("Card");  }
            }

            button1.clickeds: [own.addCard, delegator.removeCardClicked]
            button2.clickeds: [switchState, switchState]
            function switchState() {
                if (button2.state == "main") button2.state = "sub"
                else button2.state = "main"
            }
            button3.callAtClicked: delegator.viewUnload

            audioBar.source: "qrc:/DictLookup/pic/iconPronounce.png"
            audioBar.callAtClicked: delegator.clickOnSpeech
            audioBar.model: delegator.speechListModel
            audioBar.currentImage: AutoImage { source:"qrc:/pic/dictView_speechIndex.png" }
        }

        ////////////////// toolbar ends /////////////////////////////

        Item { id: details
            anchors { left: parent.left; leftMargin: 40*hRatio;
                right: parent.right; rightMargin: 40*hRatio;
                top: parent.top; topMargin: 502*vRatio+10
                bottom: parent.bottom; bottomMargin: 202*vRatio+10
            }
            GvFlickEditor { id: detailText
                anchors.fill: parent
                color: "white"
                font.pointSize: UserSettings.fontPointSize
                onReadOnlyChanged: {
                    if(!readOnly) {
                        focus: true;
                        selectAll()
                        forceActiveFocus()
                    }
                    else { deselect() }
                }
                readOnly: true
                visible: toolBar.button2.state=="main"
            }
            SynonymView { id: synonymView;
                anchors.fill: parent /* { top: parent.top; left: parent.left;right: parent.right }*/
                visible: toolBar.button2.state=="sub"
                titlePixelSize: UserSettings.fontPointSize+2
                contentPixelSize: UserSettings.fontPointSize
            }
            clip: true
            Rectangle { anchors {top: parent.top; right:parent.right }
                width: 50*vRatio; height: width
                color: detailText.readOnly ? "lightblue" : "grey"
                Text{text:"+"; anchors.centerIn:parent}
                MouseArea{ anchors.fill: parent;
                    onClicked: {
                        detailText.readOnly=!detailText.readOnly
                        detailText.myFocus = false
                    }
                }
                radius: 3; opacity: 0.6
                visible: view.state!="deck"
            }
        }
        Item{//For floatWindow
            x: 21*hRatio; y: 136*vRatio
            width: 708*hRatio; height: 336*vRatio

            ImageBrowser2 { id: imageBrowser
                anchors.fill: parent
                delegator: view.delegator
                color:"transparent"
                leftImage: "qrc:/pic/dictView_arrowLeft.png"
                rightImage: "qrc:/pic/dictView_arrowRight.png"
                enableCrop: true
                onImageBrowserClicked:{ if(!floatWindow.visible){floatWindow.show()}}
            }
        }
    }

    AutoImage { id: frame
        property real initialFrameY: 378*vRatio
        property real suggestionFrameY: 60*vRatio
        x:0; y: suggestion.suggestionExist ? suggestionFrameY : initialFrameY
        source: "qrc:/pic/dictView_blueFrame.png"
        width: parent.width; height: width*rawHeight/rawWidth
        AutoImage { id: lizard
            x:23*hRatio; y:parent.height*46/344
            source: "qrc:/pic/dictView_lizard.png"
            width: 380*hRatio; height: width*rawHeight/rawWidth
        }
        AutoImage { id: grass
            x:434*hRatio; y:parent.height*51/344
            source: "qrc:/pic/dictView_grass.png"
            width: 272*hRatio; height: width*rawHeight/rawWidth
        }
    }

    Item { id: searchFrameInit
        anchors {
            left:   parent.left;   leftMargin: 29*hRatio;
            right:  parent.right;  rightMargin: searchFrameInit.height;
            top:    frame.top;     topMargin: frame.height*205/344
            bottom: frame.bottom;  bottomMargin: frame.height*59/344
        }
    }
    Item { id: searchFrameResult
        anchors {
            left: parent.left; leftMargin: 29*hRatio;
            top:  parent.top;  topMargin: 10;
        }
        height: barHeight; width: searchFrameInit.width
    }
    Image { id: dictionaryMenu
        source: "qrc:/pic/gameSelect_whiteMenu.png"
        anchors { left: searchFrameInit.right; leftMargin: 10*vRatio;
            verticalCenter: searchFrameInit.verticalCenter
        }
        width: height
        height: searchFrameResult.height
        MouseArea {
            anchors.fill: parent
            onClicked: {
                userInput.inputText.focus = false;
                delegator.dictBtnClicked();
            }
        }
        asynchronous: true
    }
    AutoImage { id: search
        source: "qrc:/pic/dictView_searchBar.png";
        autoCalculateSize: false
        anchors.fill: searchFrameInit
        ColoredTextInput2 { id: userInput
            anchors { left: parent.left; right: parent.right;
                leftMargin: 13; rightMargin: 10;
                top: parent.top; bottom: parent.bottom; topMargin:0; bottomMargin: -2
            }
            inputText.textColor: "white";
            inputText.inputMethodHints: Qt.ImhNoPredictiveText
            clearBtnSource: "qrc:/pic/iconCancel.png"
            styleColor: "transparent"
            onReturnPressed: {
                focusOff()
                delegator.inputReturned(userInput.text, suggestion.currentIndex);
            }
            onTextChanged: delegator.textChanged(text);
            onUserClear: delegator.userClearInput();
            function focusOff() {
                userInput.inputText.focus = false;
            }
        }
    }

    SuggestionWindow { id: suggestion
        delegator: view.delegator
        width: search.width;
        anchors { top: search.bottom; left: search.left }
//        onSuggestionExist: searchFrameY = suggestionFrameY
//TODO in Android keyboard, we cannot see suggestion
    }

    FloatWindow{id: floatWindow
        targetItem: imageBrowser
        heightRatio: width*widthRatio/height
        onBackgroundClicked: end()

        AutoImage { id: searchOtherImage;
            asynchronous: true
            visible: floatWindow.visible
            source: "qrc:/pic/dictView_searchBar.png";
            autoCalculateSize: false
            width: imageBrowser.width*0.618; height: 50*vRatio
            x: parent.width/2 - width/2; y: imageBrowser.y - height - 3*vRatio

            ColoredTextInput { id: otherKey
                anchors { left: parent.left; right: parent.right;
                    leftMargin: 13; rightMargin: 10;
                    top: parent.top; bottom: parent.bottom; topMargin:3;
                }
                inputText.textColor: "white";
                clearBtnSource: "qrc:/pic/iconCancel.png"
                styleColor: "transparent"
                onReturnPressed: delegator.otherKeyWordEnturned(text);
                //: Use other key word to find other image
                hintingText.text: qsTr("Find other image")
                onVisibleChanged: {
                    if(visible){
                        inputText.focus = false
                        inputText.forceActiveFocus();
                        inputText.selectAll()
                    } else {
                        inputText.focus = false;
                    }
                }
            }
        }
    }
    Keys.enabled: true;
    Keys.onUpPressed: { keyUp() }
    Keys.onDownPressed: { keyDown() }
    function keyUp() {
        if(suggestion.height==0) return
        suggestion.currentIndex = delegator.updateIndexUp(suggestion.currentIndex);
    }
    function keyDown() {
        if(suggestion.height==0) return
        suggestion.currentIndex = delegator.updateIndexDown(suggestion.currentIndex);
    }

    QtObject { id: own
        function checkFunctionThenCall(func, param1) {
            if (typeof(func)!="undefined") { func(param1) }
        }
        function addCard() {
            var speechUrl;
            var ind = toolBar.audioBar.getCurrentIndex()
            delegator.addCardClicked(imageBrowser.getCurrentIndex(),
                                     ind);
        }
        function prepareDirectLink() {
            if(showDirectPic) {
                var qml = 'import "qrc:/../../UIControls";
                           ColoredTextInput { id: directPicture
                                property var delegator
                                anchors { left: parent.left; bottom: parent.bottom; bottomMargin: 200*vRatio}
                                width: parent.width
                                hintingText.text: "input direct picture link(internal purp)"
                                styleColor: "white"
                                opacity: 0.5
                                onReturnPressed: {
                                    inputText.focus = false
                                    delegator.setDirectLink(directPicture.text);
                                }
                            }'
                directPicture = Qt.createQmlObject(qml, view)
                directPicture.delegator = view.delegator
            }
        }
    }

    function updateResult(detail) {
        try {
            detailText.text = detail;
        } catch (error) {
            console.log("lookup failed")
        }
    }
    function getFinalResult() {
        return detailText.text
    }
    function scrollDetail(y) {
        detailText.scroll(y)
    }
    function moveDetail(dy) {
        detailText.moveY(dy)
    }

    function updateTextInput(text) {
        userInput.text = text;
        updateOtherKey(text);
    }
    function updateOtherKey(text) {
        otherKey.text = text;
    }

    function updateImageBrowser(model){
        imageBrowser.setModel(model);
    }

    function getWord() {
        return userInput.text;
    }

    function setWord(text) {
        userInput.text = text;
    }

    function updateSpeechUrl(urlList) {
        var elements = [];
        for(var i=0;i<urlList.length && i < 3;i++) {
            var ele = new
                toolBar.audioBar.getSpeechElement(
                    urlList[i], "qrc:/pic/dictView_speech"+(i+1)+".png")
            elements.push(ele);
        }
        return elements
    }

    function getSynonymView() { return synonymView; }
    function getImageBrowser() { return imageBrowser; }

    Component.onCompleted: {
        userInput.inputText.focus = false
        userInput.inputText.forceActiveFocus()
        own.prepareDirectLink()
    }
    Component.onDestruction: {
        if(typeof(directPicture)!="undefined" ) { directPicture.destroy() }
    }
}
