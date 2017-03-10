import QtQuick 2.0
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 1.3

Item {id:root
    property var settings:[] //[Mandatory]
    property var infoModelArray:[] //[Mandatory]
    property var headerInfo:[] //[Mandatory]
    property var displayTextArr: [] //[Mandatory]

    property var barImgList: [] //[Mandatory]
    property var chevronImg: [] //[Mandatory]
    property var cursorImgList: [] //[Mandatory]
    property var textColorList: [] //[Mandatory]

    property int constSpacing: 8
    property int eachRadioButtonHeight: 72*vRatio

    property alias listViewArray: listViewArray
    property alias gridView: gridView

    property bool landscape: width > height ? true : false;
    property int maxNumOfColumns: 3
    property int numberOfModel: infoModelArray.length
    property var groupArray: prepareExclusiveGroupArray()

    signal radioButtonClicked(int group)

    function prepareExclusiveGroupArray(){
        groupArray = []
        for(var i = 0; i < numberOfModel; i++){
            var newObject = Qt.createQmlObject('import QtQuick.Controls 1.3; ExclusiveGroup {}',root, "views")
            groupArray[groupArray.length] = newObject
        }
    }

    Component { id: infoDelegate
        Rectangle { id: theItem
            color: "transparent"
            property alias radioBtn: radioBtn;
            width:gridView.eachSettingWidth; height: root.eachRadioButtonHeight
            RadioButton {id: radioBtn
                checked: settings[group] == id;
                exclusiveGroup: groupArray[group];
                style: RadioButtonStyle {
                    indicator:Item{
                        width: 75*hRatio; height: root.eachRadioButtonHeight
                        AutoImage { source: cursorImgList[group%4];
                            visible: control.checked;
                        }
                    }
                }
                anchors{left: titleText.right; leftMargin: constSpacing; verticalCenter: parent.verticalCenter; }
                onClicked: {
                    settings[group] = id
                    radioButtonClicked(group)
                }
            }
            Text { id:titleText; text: displayTextArr[group][id]
                width: contentWidth; height: 41*vRatio
                x: 130*hRatio;
                color: radioBtn.checked ? textColorList[group%4] : "white"
                anchors { verticalCenter: parent.verticalCenter }
                font.pixelSize: fontTooBig; fontSizeMode: Text.VerticalFit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                MouseArea{anchors.fill: parent
                    preventStealing: true
                    onClicked: {
                        settings[group] = id
                        settings = settings
                        radioButtonClicked(group)
                    }
                }
            }
        }
    }

    Flickable{
        x: 125*hRatio; y: 29*vRatio
        width: 550*hRatio; height: 1276*vRatio
        contentHeight: gridView.height + 70*vRatio // 70 is the buffer so last item won't align bottom so such
        clip: true
        Grid{
            id: gridView
            width: parent.width; /*height: implicitHeight according to children*/
            columns: landscape ? (numberOfModel > maxNumOfColumns ? maxNumOfColumns : numberOfModel) : 1
            rows: Math.ceil(numberOfModel/columns)
    //        spacing: constSpacing*2
            property int eachSettingWidth: landscape ? (width-spacing*(columns+1))/columns : width-spacing*2;
            Repeater{
                id: listViewArray
                model: numberOfModel
                width: parent.width;
                Item{
                    property alias header: headerImage
                    width: gridView.eachSettingWidth
                    height: headerItem.height + choiceListView.height + choiceListView.anchors.topMargin
                    property alias choiceListView: choiceListView
                    Item{ id: headerItem
                        y:25*vRatio
                        width: parent.width; height: 146*vRatio
                        AutoImage{ id: headerImage
                            source: barImgList[index%4]
                            AutoImage{id: chevronImage; visible: infoModelArray[index].count == 0
                                height: parent.height*0.4; width: height;
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                source: chevronImg[index%4]
                            }
                        }

                        MouseArea{anchors.fill: headerImage; enabled: infoModelArray[index].count == 0
                            onClicked:{infoModelArray[index].action()}
                        }
                        Text { id:textItem; text: headerInfo[index]
                            x: 143*hRatio; y: 52*vRatio
                            color: textColorList[index%4]
                            width: contentWidth; height: 41*vRatio
                            font.pixelSize: fontTooBig; fontSizeMode: Text.VerticalFit
                        }
                    }

                    ListView { id: choiceListView
                        width: parent.width; height: eachRadioButtonHeight * model.count
                        anchors { top: headerItem.bottom; topMargin: -20*vRatio }
                        model: infoModelArray[index]
                        delegate: infoDelegate
                        interactive: false
                    }
                }
            }

        }
    }

    Component.onCompleted: {
        console.assert(settings.length == headerInfo.length && settings.length == infoModelArray.length
                       && settings.length == displayTextArr.length,
             "You must make sure number of items among headerInfo, settings and infoModel should be the same ")
        for(var i = 0 ; i< settings.length; i++){
            for(var j = 0 ; j < infoModelArray[i].count; j++){
                infoModelArray[i].get(j).group = i;
            }
        }
        //settings is a variant. You can only trigger property binding by assigning the whole array
        settings = settings;
    }

}





