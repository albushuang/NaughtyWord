import QtQuick 2.0
import Qt.labs.settings 1.0
import "qrc:/generalModel"
import "qrc:/gvComponent"
//import "qrc:/GameStage/StageInfo.js" as StageInfo

Rectangle {
    property DeckMedia dm
    property var limited: ["1460970032674"]
    //property Settings settings    // should be provided externally
    Settings { id: toeicBattleSettingOrg
        category: "TOEICBattle"
        property int highestAvailableStage:0
    }

    function browseCheck(order) {
        for (var i=0;i<limited.length;i++) {
            if(dm.getDeckID()==limited[i]) {
                //var stage = StageInfo.stageInfo[toeicBattleSettingOrg.highestAvailableStage]
                var stage; stage[rangeEnd] = 99999
                if (stage.rangeEnd>=order) { return true }
                else { return false }
            }
        }
        return true
    }
    function getUnlockedNumber() {
        for (var i=0;i<limited.length;i++) {
            if(dm.getDeckID()==limited[i]) {
                //var stage = StageInfo.stageInfo[toeicBattleSettingOrg.highestAvailableStage]
                var stage; stage[rangeEnd] = 99999
                return stage.rangeEnd
            }
        }
        return -1
    }
}

