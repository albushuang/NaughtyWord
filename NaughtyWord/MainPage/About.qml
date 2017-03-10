import QtQuick 2.4
import "qrc:/../UIControls"
import "qrc:/NWUIControls"
import "../generalJS/generalConstants.js" as GeneralConsts
import com.glovisdom.UserSettings 0.1

//GeneralConsts.gameNameShuffle
//<b>Music in :</b><br>
//「Barroom Ballet - Silent Film Light」of「Kevin MacLeod」<br>
//<a href=\"https://creativecommons.org/licenses/by/4.0/\"> is authorized by「Creative Commons Attribution」</a><br>
//source：http://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100310<br>
//performer：http://incompetech.com/<br><br>

//GeneralConsts.gameNameFlipMatch
//<b>Music in %2:</b><br>
//「Breaktime - Silent Film Light」of「Kevin MacLeod」<br>
//<a href=\"https://creativecommons.org/licenses/by/4.0/\"> is authorized by「Creative Commons Attribution」</a><br>
//source：http://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100302<br>
//performer：http://incompetech.com/<br><br>



Item { id: view;
    MouseArea {
        anchors.fill: parent
    }

    Image { anchors.fill: parent
        source: "qrc:/pic/background0.png"        
    }
    QtObject { id: own
        function format(txtObj) {
            txtObj.horizontalAlignment = Text.AlignHCenter
            txtObj.anchors.horizontalCenter = txtObj.parent.horizontalCenter
            txtObj.font.pointSize = UserSettings.fontPointSize
            txtObj.color = "white"
        }
    }
    Item { id: credits; width: parent.width;
        height: t1.height+10+
                t2.height+2+t21.height+2+t22.height+10+t3.height+10+
                t30.height+2+t31.height+2+t32.height+2+t33.height+2+
                t34.height+2+t35.height+10+t36.height+10+t37.height+10+
                t4.height
        x: 0
        Component.onCompleted: {
            own.format(t1)
            own.format(t2); own.format(t21); own.format(t22); own.format(t3);
            own.format(t30); own.format(t31); own.format(t32); own.format(t33)
            own.format(t34); own.format(t35); own.format(t36) ; own.format(t37)
            own.format(t4)
        }

        Text { id: t1
            text: qsTr("<b>Copyright</b><br>
                   LGPL v3<br>")
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally("https://www.facebook.com/glovisdom/")
                }
            }
        }
        Text { id: t2
            width: parent.width
            wrapMode: Text.WordWrap
            anchors { top: t1.bottom; topMargin: 10}
            //: This text will still be modified frequently, so keep untranslated.
            text: qsTr("<b>Music in %3:</b><br>
                   「Kool Kats」of「Kevin MacLeod」").arg(GeneralConsts.gameNameInsanity)
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally("http://incompetech.com/music/royalty-free/index.html?isrc=USUAN1100601")
                }
            }
        }
        Text { id: t21
            width: contentWidth < parent.width ? contentWidth : parent.width
            wrapMode: Text.WordWrap
            anchors { top: t2.bottom; topMargin: 2 }
            //: This text will still be modified frequently, so keep untranslated.
            text: qsTr("is authorized by「Creative Commons Attribution」")
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.openUrlExternally("https://creativecommons.org/licenses/by/4.0/")
                }
            }
        }
        Text { id: t22
            width: contentWidth < parent.width ? contentWidth : parent.width
            wrapMode: Text.WordWrap
            anchors { top: t21.bottom; topMargin: 2 }
            text: qsTr("performer: incompetech<br>")
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://incompetech.com/") }  }
        }

        Text { id: t3
            width: parent.width*0.8
            anchors { top: t22.bottom; topMargin: 10 }
            text: qsTr("<b>Speech search:</b><br>
                   http://shtooka.net/<br>
                   http://cdict.net/<br><br>
                   <b>Image search:</b><br>
                   http://bing.com/<br><br>
                   <b>dictionay:</b><br>
                   http://pearson.com/<br>
                   http://wiktionary.org/<br><br>
                   <b>Synonym search:</b><br>
                   http://thesaurus.altervista.org<br>")
            wrapMode: Text.WrapAnywhere
        }
        Text { id: t30
            width: parent.width*0.8
            anchors { top: t3.bottom; topMargin: 10 }
            text: qsTr("<b>Images from wikipedia.org are respectively under licenses of :</b>")
            wrapMode: Text.WordWrap
        }
        Text { id: t31
            width: contentWidth < parent.width ? contentWidth : parent.width
            anchors { top: t30.bottom; topMargin: 10 }
            text: qsTr("creative commons 2.0")
            wrapMode: Text.WordWrap
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://creativecommons.org/licenses/by-sa/2.0/") }  }
        }
        Text { id: t32
            width: contentWidth < parent.width ? contentWidth : parent.width
            anchors { top: t31.bottom; topMargin: 2 }
            text: qsTr("creative commons 2.5")
            wrapMode: Text.WrapAnywhere
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://creativecommons.org/licenses/by-sa/2.5/") }  }
        }
        Text { id: t33
            width: contentWidth < parent.width ? contentWidth : parent.width
            anchors { top: t32.bottom; topMargin: 2 }
            text: qsTr("creative commons 3.0")
            wrapMode: Text.WordWrap
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://creativecommons.org/licenses/by-sa/3.0/") }  }
        }
        Text { id: t34
            width: contentWidth < parent.width ? contentWidth : parent.width
            anchors { top: t33.bottom; topMargin: 2 }
            text: qsTr("creative commons 4.0")
            wrapMode: Text.WrapAnywhere
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://creativecommons.org/licenses/by-sa/4.0/") } }
        }
        Text { id: t35
            width: contentWidth < parent.width ? contentWidth : parent.width
            anchors { top: t34.bottom; topMargin: 2 }
            text: qsTr("GNU Free Documentation License<br>")
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://www.gnu.org/licenses/old-licenses/fdl-1.2.html") } }
            wrapMode: Text.WrapAnywhere
        }
        Text { id: t36
            width: parent.width*0.8
            anchors { top: t35.bottom; topMargin: 10 }
            text: qsTr("<b>Licenses of http://www.freeimages.com/</b><br>")
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("http://www.freeimages.com/license") } }
            wrapMode: Text.WordWrap
        }
        Text { id: t37
            width: parent.width
            anchors { top: t36.bottom; topMargin: 10 }
            text: qsTr("<b>License of https://pixabay.com/</b><br>")
            MouseArea { anchors.fill: parent ; onClicked: { Qt.openUrlExternally("https://pixabay.com/zh/service/terms/#usage") } }
            wrapMode: Text.WordWrap
        }
        Text { id: t4
            width: parent.width*0.8
            anchors { top: t37.bottom; topMargin: 10 }
            text: qsTr("<b>All trademarks, service marks, trade names, trade dress, product names and logos appearing on this app are the property of their respective owners.</b>")
            wrapMode: Text.WordWrap
        }
        onYChanged: {
            if (y+height < 0) {
                y = parent.height
            }
        }
    }
    Timer { id: scroll
        interval:20; repeat: true; running: true
        onTriggered: {
            credits.y -= 2;
        }
    }

    DragMouseAndHint {
        target: view;
        maxX: view.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
    }
    MouseArea { anchors { top: parent.top; right: parent.right}
        width: parent.width*0.8
        height: parent.height
        onClicked: {
            scroll.running = !scroll.running
            mouse.accepted = false
        }
        propagateComposedEvents: true
    }

    Component.onCompleted: {
        credits.y = 800
        scroll.start();
    }
}


