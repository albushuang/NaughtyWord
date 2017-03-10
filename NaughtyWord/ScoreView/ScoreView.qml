import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.3
import "qrc:/../../UIControls"
import "../generalJS/generalConstants.js" as GeneralConsts
import "scoreConsts.js" as Consts

// add delegate for protocol
Item {id: root
    signal repeatGameClicked()
    signal backToMenuClicked()
    signal enterClicked(string name)
    property variant protocolDelegator

    property int tableHeaderHeight
    property int viewType: Consts.idLocal
    property string gameName
    property string gameType
    property string gameEasiness
    property alias infoModel:infoModel
    property alias nameInput:nameInput
    property int borderWidth: 2
    property bool needUserTypeName: false
    property bool idLandScape: parent.width>parent.height
    property int headerHeight: pixelDensity * 20 //120
    property int itemHeight: pixelDensity * 5 //30
    property int allSpacing: pixelDensity * 1 //5
    property int bodyHeight: getBodyHeight()
    property int footerHeight: pixelDensity * 5//30
    property string addtionalCoins: ""
    property bool showSrvScore
    property bool isPracticeMode
    width: pixelDensity * 50 //360
    height: Math.min(headerHeight + bodyHeight + footerHeight + 4*allSpacing, parent.height)
    anchors.centerIn: parent

    function getBodyHeight(){
        var numOfItems = Math.floor((parent.height - headerHeight - footerHeight - 4*allSpacing)/(itemHeight + allSpacing)) -1
        numOfItems = Math.min(6,numOfItems)
        return numOfItems* (itemHeight + allSpacing)
    }

    function updateGameInfo(infoElements) {
        gameInfo.clear();
        for(var i = 0; i < infoElements.length; i++){
            gameInfo.append(infoElements[i])
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        AutoImage{id: tabLocal
            property bool onThis: root.viewType == Consts.idLocal
            source: "qrc:/ScoreView/tab" + (onThis ? 1 : 0 )+ ".png"
            x: 30*hRatio + (onThis? 0 : 12*hRatio) ; y: -height + (onThis ? 20.8*vRatio : 2*vRatio)
            z: onThis? 2:0
            MouseArea{
                anchors.fill: parent;
                onClicked:{
                    if(root.viewType != Consts.idLocal){
                        protocolDelegator.pageClicked(Consts.idLocal)
                    }
                }
            }
        }
        Text{id: textLocal; z: 3
            text: Consts.strBtnType[Consts.idLocal]
            x: 85*hRatio; y:-55*vRatio
            width: 200*hRatio; height: 50*vRatio
            font.pixelSize: iFontSize; fontSizeMode: Text.Fit; font.bold: true
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        AutoImage{id: tabGlobal
            property bool onThis: root.viewType == Consts.idGlobal
            source: "qrc:/ScoreView/tab" + (onThis ? 1 : 2 )+ ".png"
            x: tabLocal.x + tabLocal.width - 18*hRatio ; y: -height + (onThis ? 20.8*vRatio : 2*vRatio)
            z: onThis? 2:0
            MouseArea{
                anchors.fill: parent;
                enabled: !(viewType == Consts.idLocal && needUserTypeName)
                onClicked:{
                    if(root.viewType != Consts.idGlobal){
                        protocolDelegator.pageClicked(Consts.idGlobal)
                    }
                }
            }
        }
        Text{id: globalText; z:3
            text: Consts.strBtnType[Consts.idGlobal];
            x: 345*hRatio; y: textLocal.y
            width: textLocal.width; height: textLocal.height
            font.pixelSize: textLocal.font.pixelSize;fontSizeMode: textLocal.fontSizeMode; font.bold: textLocal.font.bold
            horizontalAlignment: textLocal.horizontalAlignment; verticalAlignment: textLocal.verticalAlignment
        }

        Rectangle{ id: table
            clip: true
            color: "white"; radius: 19*hRatio
            width: parent.width*1380/1496; height: parent.height*716/735
            anchors { top: parent.top; left: parent.left }

            AutoImage {
                source: "qrc:/pic/scoreBG.png"
                anchors.fill: parent
            }
            AutoImage { id: titleImage; source: "qrc:/pic/scoreTitle.png"
                width: parent.width*350/666; height: parent.height*118/719*0.95
                x: parent.width*168/717; y: parent.height*37/735*0.95
                Item {
                    x: parent.width*62/350; y: parent.height*15/118*0.975
                    width: parent.width*290/350;height: parent.height*101/118*0.95
                    Text {
                        anchors.centerIn: parent
                        text: gameName; font.bold: true
                        width: parent.width * 0.6
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        font.pixelSize: fontTooBig
                        fontSizeMode: Text.Fit
                        color: "#ffcc66"
                    }
                }
            }

            GridView { id: infoGrid;
                anchors {top: titleImage.bottom; horizontalCenter: parent.horizontalCenter }
                width: parent.width*0.9;
                height: parent.height*2*59/716*0.95
                cellWidth: width/2; cellHeight: height/2;
                flickableDirection: Flickable.VerticalFlick
                flow: GridView.FlowLeftToRight;
                delegate: infoCell
                model: gameInfo
                clip: true
                ListModel { id: gameInfo }
            }
            Component { id: infoCell
                Item { width: infoGrid.cellWidth; height:infoGrid.cellHeight;
                    Text { id: infoTitleObj;
                        width: parent.width*4/10; height: parent.height
                        font.pixelSize: fFontSize;fontSizeMode: Text.Fit; font.bold: true;
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
                        anchors { left: parent.left; top: parent.top }
                        text: infoTitle
                        wrapMode: Text.WrapAnywhere
                    }
                    AutoImage {
                        width: parent.width*6/10; height: parent.height*0.8
                        anchors { left: infoTitleObj.right; verticalCenter: parent.verticalCenter }
                        source:"qrc:/pic/scoreInfoBar.png"
                        FlickableText {
                            text: information
                            anchors{ top: parent.top; bottom: parent.bottom; left: parent.left;
                                right:parent.right; margins: 5*hRatio}
                            font.pixelSize: fFontSize;
                            color: "#A90036"
                        }
                    }
                }
            }


            AutoImage { id: header;
                width: listView.width-listView.width*19/662*2; height: tableHeaderHeight
                anchors { horizontalCenter: parent.horizontalCenter; top: infoGrid.bottom }
                source: "qrc:/pic/scoreTableItem.png"
                property variant startingPoint: [0, 0.33, 0.66]
                property variant widthRatio: [0.33, 0.33, 0.33]
                Item {
                    x: header.startingPoint[0] * parent.width; y:0
                    width: parent.width*header.widthRatio[0]; height: parent.height
                    Text { id:nameTxt; text: GeneralConsts.txtName; anchors.fill: parent
                        font.pixelSize: mFontSize;fontSizeMode: Text.Fit; font.bold: true;
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
                    }
                }
                Item {
                    x: header.startingPoint[1] * parent.width; y:0
                    width: parent.width*header.widthRatio[1]; height: parent.height
                    Text { id:scoreTxt; text: GeneralConsts.txtScore; anchors.fill: parent
                        font.pixelSize: mFontSize;fontSizeMode: Text.Fit; font.bold: true;
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
                    }
                }
                Item {
                    x: header.startingPoint[2] * parent.width; y:0
                    width: parent.width*header.widthRatio[2]; height: parent.height
                    Text { id:timeTxt; text: GeneralConsts.txtTime; anchors.fill: parent
                        font.pixelSize: mFontSize;fontSizeMode: Text.Fit; font.bold: true;
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
                    }
                }
                Component.onCompleted: {
                    formatHeaderText(nameTxt);
                    formatHeaderText(scoreTxt);
                    formatHeaderText(timeTxt);
                }

                function formatHeaderText(target) {
                    target.anchors.fill = target.parent
                    target.fontSizeMode = Text.Fit;
                    target.font.bold = true;
                    target.horizontalAlignment = Text.AlignHCenter;
                    target.verticalAlignment = Text.AlignVCenter;
                    target.font.pixelSize = 20;
                    target.color = "#A90036";
                }
            }

            ListView { id: listView
                anchors { left: parent.left; top: header.bottom }
                width: parent.width; height: parent.height*390/718*0.95 - tableHeaderHeight;
//                header: headerComponent //header component is shit. make one on my own
//                headerPositioning: ListView.OverlayHeader
                model: infoModel
                delegate: infoDelegate
                clip: true
            }

            ListModel { id: infoModel }

            Component { id: infoDelegate
                Item{
                    property variant startingPoint: [0, 0.33, 0.66]
                    property variant widthRatio: [0.33, 0.33, 0.33]
                    width: parent.width; height: parent.width*70/663
                    Item {
                        width: listView.width-listView.width*19/662*2; height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top
                        Image { anchors.fill: parent; source: "qrc:/pic/scoreTableItem.png"
                            opacity: index%2==1 ? 1: 0.5
                        }
                        Item { x: startingPoint[0] * parent.width
                            width: parent.width*widthRatio[0]; height: parent.height
                            Text { id:nameTxt; text: name; color: "#336699"
                                width: parent.width; height: parent.height*0.62
                                anchors{horizontalCenter: parent.horizontalCenter;
                                    top: parent.top; topMargin: parent.height*0.02}
                                font.pixelSize: fontTooBig; fontSizeMode: Text.Fit; minimumPixelSize: 3
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignBottom
                            }

                            Text { id:titleTxt; text: studyTitle; color: "#336699"
                                 width: parent.width; height: parent.height*0.40
                                 anchors{horizontalCenter: parent.horizontalCenter; top: nameTxt.bottom; topMargin: -parent.height*0.03 }
                                 font.pixelSize: fontTooBig; fontSizeMode: Text.Fit; minimumPixelSize: 3
                                 horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
                            }
                        }
                        Item { x: startingPoint[1] * parent.width
                            width: parent.width*widthRatio[1]; height: parent.height
                            Text { id:scoreTxt; text: score }
                        }
                        Item { x: startingPoint[2] * parent.width
                            width: parent.width*widthRatio[2]; height: parent.height
                            Text { id:timeTxt; text: (time/1000).toFixed(1) }
                        }
                    }
                    Component.onCompleted: {
                        formatItemText(scoreTxt);
                        formatItemText(timeTxt);
                    }
                    function formatItemText(target) {
                        target.anchors.fill = target.parent
                        target.font.pixelSize = target.parent.height/1.7
                        target.fontSizeMode = Text.Fit
                        target.horizontalAlignment = Text.AlignHCenter
                        target.verticalAlignment = Text.AlignVCenter
                        target.color = "#336699"
                    }
                }
            }

            ColoredTextInput {
                id: nameInput
                radius: 4
                inputText.focus: false
                inputText.font.pixelSize: height/2;
                width: parent.width * (1-0.618); height: needUserTypeName ? parent.height*59/716*0.95 : 0
                anchors{horizontalCenter: parent.horizontalCenter; leftMargin: allSpacing;
                    top: listView.bottom; topMargin: 0.6*allSpacing}
                styleColor: "#ECECEC"
                visible: needUserTypeName
                hintingText.text: qsTr("Your name")
                inputText.inputMethodHints: Qt.ImhNoPredictiveText
                inputText.validator: RegExpValidator{regExp: /[\x4e00-\x9fa5\dA-Za-z ]{0,7}|[\dA-Za-z ]{0,11}/}
                /*regExp: 中英文混搭最多7個字or單純英文數字最多11個字*/
                onReturnPressed: mouseConfirm.clicked("");
            }

            AutoImage{
                source: "qrc:/pic/buttonOK.png"
                anchors {left: nameInput.right; leftMargin: 10; verticalCenter: nameInput.verticalCenter }
                width: height; height: nameInput.height*0.9
                visible: nameInput.height != 0
                MouseArea{ id: mouseConfirm
                    anchors.fill: parent
                    onClicked:{
                        if(nameInput.text != ""){
                            //enterClicked(nameInput.text)
                            nameInput.inputText.focus = false
                            if(typeof(protocolDelegator) != "undefined") {
                                protocolDelegator.enterClicked(nameInput.text);
                            }
                        }
                    }
                }
            }

            Item{
                id: repeatButton
                width: parent.width * 59/662; height: parent.height * 56/718*0.95
                anchors {top: listView.bottom; topMargin: parent.height * 12/718*0.95
                left: parent.left; leftMargin: parent.width * 245/662}
                AutoImage {anchors.fill: parent; source: "qrc:/pic/scorePlayAgain.png"}
                visible: !needUserTypeName
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        //repeatGameClicked()
                        if (typeof(protocolDelegator) != "undefined") {
                            protocolDelegator.repeatGameClicked();
                        }
                    }
                }
            }

            Item{
                id: backToMenuButton
                width: parent.width * 59/662; height: parent.height * 56/718*0.95
                anchors {top: listView.bottom; topMargin: parent.height * 12/718*0.95
                left: repeatButton.right; leftMargin: parent.width * 73/662}
                visible: !needUserTypeName
                AutoImage { anchors.fill: parent; source: "qrc:/pic/scoreBack.png" }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        //backToMenuClicked()
                        if (typeof(protocolDelegator) != "undefined") {
                            protocolDelegator.backToMenuClicked();
                        }
                    }
                }
            }
        }
        AutoImage {
            source: "qrc:/pic/scoreSnake.png"
            anchors { bottom: parent.bottom; right: parent.right }
            width: parent.width*143/770; height:width*233/143
        }
    }
}

