import QtQuick 2.0
import QtQuick.Controls 1.4
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import "../generalModel"
import "../generalJS/objectCreate.js" as CompCreator

NWRadioBtnSettings {id: root;
    infoModelArray: [callDeckControllerModel, callAnkiControllerModel,
        musicModel, soundEffectModel, languageModel, textSizeModel, callRebuildDeckModel]
    displayTextArr: [
        [],
        [],
        [off, on],
        [on, qsTr("Games sounds OFF"), qsTr("All sounds OFF")],
        {en:"English", tc:"繁中", sc:"简中"},
        [qsTr("Small"), qsTr("Medium"), qsTr("Large")],
        []
    ]
    headerInfo: [qsTr("Decks"), qsTr("Anki Decks"), qsTr("Music"), qsTr("Sound"),
                 qsTr("language"), qsTr("Font size"), qsTr("Rebuild decks")];

    settings: ["", "", UserSettings.musicON, own.getSound(),
               "", (UserSettings.fontPointSize-16)/4, ""]

    viewController: stackView
    property var on: qsTr("ON")
    property var off: qsTr("OFF")

    AppSettings{id: appSettings
        Component.onCompleted:{
            settings[4] = appSettings.readSetting("NaughtyWord/Language")
        }
    }

    ListModel { id: languageModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: "en", group: -1 })
            append({id: "tc", group: -1 })
            append({id: "sc", group: -1 })
        }
    }

    ListModel { id: textSizeModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
            append({id: 2, group: -1 })
        }
    }

    ListModel { id: musicModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
        }
        // false == 0, true == 1
    }

    ListModel { id: soundEffectModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
            append({id: 2, group: -1 })
        }
    }

    ListModel { id: callDeckControllerModel
        function action(){
            stackView.vtSwitchControl("qrc:/deckManagement/DeckManagementController.qml", {}, false, false, true);
        }
    }

    ListModel { id: callAnkiControllerModel
        function action(){
            stackView.vtSwitchControl("qrc:/deckManagement/AnkiPackageController.qml", {}, false, false, true);
        }
    }

    ListModel { id: callRebuildDeckModel
        function action(){
            var obj = CompCreator.instantComponent(root, "qrc:/MainPage/InitDecks.qml",
                        {width: root.width, height: root.height, callback: deleteLater2 })
            later.toDo = function() { obj.start(true) }
            later.start()
        }
        function deleteLater2(obj) {
            later.toDo = obj.destroy
            later.start()
        }
    }
    Timer { id: later
        property var toDo
        triggeredOnStart: false;
        interval: 1
        repeat: false
        onTriggered: { toDo() }
    }


    Component.onCompleted: {
    }

    Component.onDestruction: {
        UserSettings.fontPointSize = settings[5]*4+16
        UserSettings.musicON = settings[2]
        own.setSound(settings[3])

        var originalLanguage = appSettings.readSetting("NaughtyWord/Language")
        if(originalLanguage != settings[4]){
            appSettings.writeSetting("NaughtyWord/Language", settings[4])
            var qmlString = 'import SystemOperation 0.1; SystemOperation { }';
            var restart = Qt.createQmlObject(qmlString, stackView);
            restart.restartApp()
        }
    }

    QtObject { id: own
        function getSound() {
            if (UserSettings.soundAllON && UserSettings.soundGameON) return 0
            if (UserSettings.soundAllON && !UserSettings.soundGameON) return 1
            if (!UserSettings.soundAllON) return 2
        }
        function setSound(v) {
            if (v==0) {
                UserSettings.soundGameON = true
                UserSettings.soundAllON = true
            }else if (v==1) {
                UserSettings.soundGameON = false;
                UserSettings.soundAllON = true;
            }else if(v==2) {
                UserSettings.soundGameON = false;
                UserSettings.soundAllON = false;
            }
        }
    }
}

