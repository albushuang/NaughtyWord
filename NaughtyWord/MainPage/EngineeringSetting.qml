import QtQuick 2.0
import QtQuick.Controls 1.4
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import Qt.labs.settings 1.0
import "qrc:/GameTOEICBattle"
import "qrc:/gvComponent"
import "../generalModel"
import "../generalJS/objectCreate.js" as CompCreator

NWRadioBtnSettings {id: root;
    infoModelArray: [infoModel0, infoModel1, infoModel2, infoModel3,
        pureHeaderModel3, pureHeaderModel4, pureHeaderModel5
        //,pureHeaderModel6
    ]
    headerInfo: [qsTr("language"),
        "Direct URL",
        "Automatic dictionaty",
        "搜尋圖片種類",
        qsTr("Reset tutorials"),
        qsTr("Show hints again"),
        qsTr("User terms")
        //,qsTr("Super User")
    ];
    displayTextArr: [
        {en:"English", tc:"繁中", sc:"简中"},
        ["hide", "show"],
        ["hide", "show"],
        ["Normal", "For commercial release"],
        [],
        [],
        []
        //,[]
    ]

    viewController: stackView

    AppSettings{id: appSettings
        Component.onCompleted:{
            settings = [appSettings.readSetting("NaughtyWord/Language"),
                        UserSettings.directLink,
                        UserSettings.autoDict,
                        UserSettings.searchForCommercial,
                        "","",""
                        //,""
            ]
        }
    }

    ListModel { id: infoModel0
        Component.onCompleted: {//group will be automatically assigned later
            append({id: "en", group: -1 })
            append({id: "tc", group: -1 })
            append({id: "sc", group: -1 })
        }
    }

    ListModel { id: infoModel1
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
        }
    }

    ListModel { id: infoModel2
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
        }
    }

    ListModel { id: infoModel3
        Component.onCompleted: {//group will be automatically assigned later
            append({id: 0, group: -1 })
            append({id: 1, group: -1 })
        }
    }

    ListModel { id: pureHeaderModel3
        function action(){
            UserSettings.resetAllTutorial()
        }
    }

    ListModel { id: pureHeaderModel4
        function action(){
            UserSettings.showAllReminderAgain()
        }
    }

    ListModel { id: pureHeaderModel5
        function action(){
            UserSettings.termsAccepted = false
        }
    }

//    ListModel { id: pureHeaderModel6
//        function action(){
//            if(parseInt(sp.toeicGold)<1000) {
//                sp.toeicGold = "9999999"
//                sp.toeicDiamond = "9999"
//                sp.tripleCard = "9999"
//                ss.toeicBattleLevel =  "99"
//                sp.delayCard = "9999"
//                message("Super user", 1500)
//            } else {
//                sp.toeicGold = "120"
//                sp.toeicDiamond = "0"
//                sp.tripleCard = "0"
//                sp.delayCard = "0"
//                sp.eliminateCard = "0"
//                ss.toeicBattleLevel =  "99"
//                ss.highestAvailableStage = 0
//                message("Initial user", 1500)
//            }
//        }
//    }
    function message(msg, time) {
        var message = CompCreator.instantComponent(root,
                        "qrc:/gvComponent/FadingMessage.qml",
                        {width: root.width*0.8, height: root.height*0.2} )
        message.theText.text = msg
        message.theText.color = "orange"
        message.life = time
        message.show()
    }

    Settings { id: ss
        category: "TOEICBattle"
        property string toeicBattleLevel
        property int highestAvailableStage
    }
    //TOEICBattleProperty { id: sp }

    Component.onDestruction: {
        appSettings.writeSetting("NaughtyWord/Language", settings[0])
        UserSettings.directLink = settings[1]
        UserSettings.autoDict = settings[2]
        UserSettings.searchForCommercial = settings[3]
    }

}

