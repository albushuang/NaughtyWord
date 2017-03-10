import QtQuick 2.0
import "qrc:/../UIControls"
import "../generalJS/deckCategoryConsts.js" as CateConst
Item {id: root; anchors.fill: parent
    signal cloudClicked()
    signal viewUnload()
    signal deckCategoryClicked(int id)

    Image{anchors.fill: parent
        source: "qrc:/pic/background0.png"
    }
    AutoImage{
        x:0; y:64*vRatio
        source: "qrc:/pic/deckManagement_BG with graphics.png"
    }
//    AutoImage{id: goBack
//        x:10; y:355*vRatio
//        source: "qrc:/pic/deckManagement_leave icon.png"
//        MouseArea{anchors.fill: parent; onClicked: {viewUnload()}}
//    }

    Item{width: historyImg.width; height: historyImg.height + historyTxt.height
        x:164*hRatio; y: 392*vRatio
        AutoImage{id: historyImg
         source: "qrc:/pic/deckManagement_cloud icon.png"
        }
        Text{id: historyTxt; color: "white"
            anchors{top: historyImg.bottom; horizontalCenter: historyImg.horizontalCenter}
            width: 110*hRatio; height: 40*vRatio
            text: CateConst.disCloud
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            font.pixelSize: fontTooBig; fontSizeMode: Text.Fit
        }
        MouseArea{anchors.fill: parent
            onClicked:{cloudClicked()}
        }
    }

    Repeater{id: categories;model: 6
        property variant ids: [ CateConst.idTest, CateConst.idSchool, CateConst.idProfession,
            CateConst.idLife, CateConst.idEntertainment, CateConst.idTravel
        ]
//TODO move to model, repeater can use model as well
        property variant categoryTextArr: [
            CateConst.disTest,
            CateConst.disSchool,
            CateConst.disProfession,
            CateConst.disLife,
            CateConst.disEntertainment,
            CateConst.disTravel
        ]
        property variant imgSourceArr: ["deckManagement_test icon.png", "deckManagement_school icon.png",
            "deckManagement_profession icon.png", "deckManagement_living icon.png",
            "deckManagement_entertainment icon.png", "deckManagement_travel icon.png"
        ]

        property variant positionArr: [Qt.point(41,680),Qt.point(262,680),Qt.point(482,680),
            Qt.point(78,1003),Qt.point(301,1003),Qt.point(523,1003) ]

        Item{width: eachImg.width; height: eachImg.height + eachTxt.height
            x:categories.positionArr[index].x*hRatio; y: categories.positionArr[index].y*vRatio
            AutoImage{id: eachImg
             source: "qrc:/pic/" + categories.imgSourceArr[index]
            }
            Text{id: eachTxt; color: "white"
                anchors{top: eachImg.bottom; horizontalCenter: eachImg.horizontalCenter}
                width: 166*hRatio; height: 40*vRatio
                text: categories.categoryTextArr[index]
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                font.pixelSize: 22; fontSizeMode: Text.Fit
            }
            MouseArea{anchors.fill: parent
                onClicked:{deckCategoryClicked(categories.ids[index])}
            }
        }
    }
}

