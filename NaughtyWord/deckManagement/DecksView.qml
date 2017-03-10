import QtQuick 2.0
import "qrc:/../../UIControls"
import "qrc:/generalJS/deckCategoryConsts.js" as CateConst

Item { id: root
    property string bgImg
    property variant folderModel//: listView.model
    property alias categoryModel: categorySelection.model
    property alias decksListView: listView   //alias for tutorial
    property bool autoDict: false

    function categoryShow(){
        categorySelection.visible = true
    }

    signal caregoryIconClicked()
    signal deckClicked(string fileName, int index);
    signal deckPressAndHold(int index);
    signal backClicked()
    signal categoryClicked(string settingKey, int index, bool isOn)
    signal categorySelectionEnd()
    signal autoDictClicked(string fileName, int index)

    anchors.fill: parent
    Image{source: "qrc:/pic/background0.png"}


    AutoImage{id: background
        source: "qrc:/pic/" + bgImg
        x:0; y: 142*vRatio; width: 740*hRatio; height:1193*vRatio
        MouseArea{id: categoryIconMouse
            x: 252*hRatio; y:0
            width: 247*hRatio; height: 253*vRatio
            onClicked: {caregoryIconClicked()}
        }
    }


//TODO Shadow: 上一頁按鈕位置不一致
//    AutoImage{id: back; z:1
//        source: "qrc:/pic/Back icon.png"
//        x: 44*hRatio; y:299*vRatio
//        MouseArea{anchors.fill: parent; onClicked: { backClicked()}}
//    }

    ListView { id: listView
        width: 637*hRatio; height: 885*vRatio
        x: 58*hRatio; y: 436*vRatio
        spacing: 16*vRatio
        clip: true

        Component { id: deckDelegate
            Item{
                width: cellBackground.width; height: cellBackground.height
                AutoImage{id: cellBackground
                    source: "qrc:/pic/decksView_white area.png"
                }
                FlickableText{
                    text: fileName.replace(/\..*/, "")
                    anchors {verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter}
                    width: 587*hRatio; height: 59*vRatio
                    color: "black"
                    font.pixelSize: fontTooBig
                    textMouse.onClicked:{
//                        console.log("filename:", fileName, "filter", folderModel.nameFilters)
//                        console.log("model count", folderModel.count)
                        deckClicked(fileName, index)
                    }
                    textMouse.onPressAndHold:{
                        //if model is folderModel, we cannot get that modelItem by listView.model.get(index)
                        deckPressAndHold(index/*, listView.model.get(index)*/)
                    }
                }

                Image { id: autoDictBtn
                    source: "qrc:/pic/gameSelect_diamond.png"
                    anchors { right: parent.right; rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    width: 30; height: 30
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { autoDictClicked(fileName, index) }
                    }
                    visible: autoDict
                }
            }
        }
        model: folderModel
        delegate: deckDelegate
    }


    Rectangle{id: cateBg; color:"#9ac6c5"; radius: 5; visible: categorySelection.visible
        anchors.centerIn: categorySelection;
        width: categorySelection.width + border.width*2; height: categorySelection.height + border.width*2;
        border{color: "white"; width: 3}
    }
    MouseArea{id: categoryMouseStealer; anchors.fill: parent; visible: categorySelection.visible; z:2
        onClicked: {
            categorySelection.visible = false
            categorySelectionEnd()
        }
    }

    GridView{id: categorySelection; visible: false; z:3
        anchors.centerIn: parent
        width: 407*hRatio; height: 338*vRatio
        cellWidth: 127*hRatio; cellHeight: 164*vRatio
        delegate: cellDelegate
        Component{id: cellDelegate
            Item{id: iconItem
                width: iconImg.width; height: iconImg.height + iconText.height
                AutoImage{id: iconImg
                    x:17*hRatio; y:17*vRatio
                    source: "qrc:/pic/" + (isFilterOn ? imgSrcOn : imgSrcOff)
                }
                Text{id: iconText; text: txt; color: "white"
                    anchors{left: iconImg.left; top: iconImg.bottom}
                    width: iconImg.width; height:37*vRatio
                    font.pixelSize: 16; fontSizeMode: Text.Fit
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                MouseArea{ anchors.fill: parent; onClicked: {
                    categoryClicked(key, index, !isFilterOn)}
                }
            }
        }
    }

}
