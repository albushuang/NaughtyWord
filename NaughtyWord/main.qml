import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import AppSettings 0.1
import QtQml 2.2
import com.glovisdom.UserSettings 0.1
import QmlAdMob 0.1
import "qrc:/../UIControls"
import "qrc:/NWComponents"
import "generalJS/generalConstants.js" as GeneralConsts
import "generalJS/usageServer.js" as UsageServer
import "generalJS/appsettingKeys.js" as AppKeys

ApplicationWindow { id: application
    title: GeneralConsts.appName
    x: isDeskTop() ? Screen.width/2 - width/2 : 0
    width: isDeskTop() ? 576 : Screen.width
    height: isDeskTop() ? 1024 :Screen.height
    visible: true
    visibility: isDeskTop() ? "Windowed" : "FullScreen"

    onClosing: {
        if(Qt.platform.os === "android"  ){
            if(stackView.depth > 1){
                close.accepted = false
                var dontPop = false
                for(var i = 0; i < stackView.viewCannotBePoppedByBackKey.length; i++){
                    if(stackView.viewCannotBePoppedByBackKey[i] == stackView.currentItem){
                        dontPop = true
                    }
                }
                if(!dontPop){
                    stackView.pop()
                }
            }else{
                if(askForLeave) { return }
                else {
                    invisible.stop()
                    confirmLeave.opacity = 1
                    invisible.start()
                    askForLeave = true
                    close.accepted = false
                }
            }
        }else{return}
    }
    property bool askForLeave: false
    property real hRatio: width/750
    property real vRatio: height/1334
    property int hFontSize: pixelDensity * 5;
    property int iFontSize: pixelDensity * 4.5;
    property int mFontSize: pixelDensity * 4;
    property int nFontSize: pixelDensity * 3.5;
    property int pFontSize: pixelDensity * 3;
    property int fFontSize: pixelDensity * 2;
    property int fontTooBig: iFontSize * 999
    property real pixelDensity: Screen.pixelDensity;

    NWStackView {
        property alias adMob: adMob
        id: stackView
        anchors.fill: parent
        onDepthChanged: {
            askForLeave = false
        }
        QmlAdMob { id: adMob
            Component.onCompleted: {
                adMob.initRewardedVideoAd(["EE000000000000000000000000000003", "9900000000000000000000000000000A"])
            }
        }
        function popAndDelete(objArray) {
            stackView.pop()
            if (typeof(objArray) != "undefined") {
                later.array = objArray
                later.start()
            }
        }
        Timer { id: later; interval: 10; repeat: false
            property var array
            onTriggered: {
                for (var i=0;i<array.length;i++) {
                    array[i].destroy()
                }
            }
        }
    }
    Rectangle { id: confirmLeave
        color: "white"; opacity: 0
        width: stackView.width; height: stackView.height/10
        anchors { bottom: parent.bottom; left: parent.left }

        Text { anchors.fill: parent
            text: qsTr("One more click to leave app.")
            font.pointSize: 24
            color: "blue"
            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter;
        }
        NumberAnimation on opacity { id: invisible
            running: false; to: 0; duration: 3000
        }
    }

    function isDeskTop(){
        return Qt.platform.os === "windows" || Qt.platform.os === "osx" ||
               Qt.platform.os === "linux" || Qt.platform.os === "unix"
    }


    AppSettings { id: appSettings }
    function saveUsageRecords(){
        var path = "usage records/" + UserSettings.uuid
        var gameRecordStr = appSettings.readSetting(AppKeys.gameRecords)
        if(typeof(gameRecordStr) == "undefined" ){
            gameRecordStr = "{}"
        }
        if(typeof(gameRecordStr) == "object" ){
            /* In old design, appSettings.readSetting(AppKeys.gameRecords) returns an object. In this case,
            we should convert it to string first. In new design, this condition shouldn't be entered.*/
            gameRecordStr = JSON.stringify(gameRecordStr)
        }
        var gameRecords = JSON.parse(gameRecordStr)
        var newData= {
            legibleName: UserSettings.lastInputName,
            game: gameRecords,
            dictinoary: {
                searchCount: UserSettings.searchCount,
                useOtherKeyCount: UserSettings.useOtherKeyCount,
                addCardCount: UserSettings.addCardCount
            }
        }

        UsageServer.saveUsageRecords(path, newData)
    }
    Component.onCompleted: {
        stackView.switchControl("qrc:/MainPage/MainPageController.qml", {}, false, false, true);
        saveUsageRecords()
    }
}
