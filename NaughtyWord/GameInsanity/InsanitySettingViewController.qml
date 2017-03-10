import QtQuick 2.0
import "../generalModel"
import "settingValues.js" as Value
import "../generalJS/generalConstants.js" as GeneralConsts


NWRadioBtnSettings {id: root
    infoModelArray: [gameModeModel, cardTypeModel, ]
    displayTextArr: [Value.stringGameType, GeneralConsts.stringCardType]
    settings: [appSettings.gameType, appSettings.cardType]
    property variant appSettings
    viewController: stackView
    headerInfo: [
//: The image or spelling mode
        GeneralConsts.txtGameMode,
//: question
        GeneralConsts.txtGameQuestionPool
    ];

    signal settingUpdated(variant appSettings)

    ListModel { id: gameModeModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: Value.image, group: -1 })
            append({id: Value.spelling, group: -1 })
        }
    }

    ListModel { id: cardTypeModel
        Component.onCompleted: {//group will be automatically assigned later
            append({id: GeneralConsts.gameAllWordID, group: -1 })
            append({id: GeneralConsts.gameTodayPracticedID, group: -1 })
            append({id: GeneralConsts.gameAllPracticedID, group: -1 })
        }
    }

    Component.onDestruction: {
        appSettings.gameType = settings[0]
        appSettings.cardType = settings[1]

        settingUpdated(appSettings)
    }
}



