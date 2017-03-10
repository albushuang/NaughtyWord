import QtQuick 2.0
import "qrc:/gvComponent"
Row{id: multiBtns;
    property variant showTexts  //[Mandatory]
    property variant enabledArray  //[Mandatory]
    property int nuberOfBtns: showTexts.length
    property int selectedIdx: 0 //[Optional]
    property variant hightlightColor: "black"
    property int fontPointSize: 15   
    signal clicked(int index)
    Repeater{ id: btnArray   
        model: multiBtns.nuberOfBtns;
        Rectangle{id: eachBtn
            color: "#f5f5f5"
            width: multiBtns.width/multiBtns.nuberOfBtns; height: multiBtns.height
//            radius: Math.min(width, height)
            CenterText{id: buttonTxt
                text: multiBtns.showTexts[index]
                width: parent.width*0.9; height: parent.height*0.9
                wrapMode: Text.WordWrap
            }
            MouseArea{anchors.fill: parent
                onClicked: {
                    if(multiBtns.enabledArray[index]){
                        multiBtns.clicked(index)
                        multiBtns.selectedIdx= index
                    }
                }
            }
            Rectangle{id: disabledBlock;
//                radius: parent.radius
                color: "#8d8d8d"; opacity: 0.7;
                anchors.fill: parent;
                visible: index != multiBtns.selectedIdx
            }
            Rectangle{id: highlightBlock;
//                radius: parent.radius
                color: "transparent";
                anchors.fill: parent;
                visible: index == multiBtns.selectedIdx
                border.color: hightlightColor
                border.width: 1.5
            }
        }
    }

}

