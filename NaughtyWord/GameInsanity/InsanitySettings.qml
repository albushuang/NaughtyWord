import QtQuick 2.0
import Qt.labs.settings 1.0
import "settingValues.js" as Values
import "../generalJS/generalConstants.js" as GeneralConsts

Settings {
    category: "Insanity"

    property int gameType: Values.image
    property int easiness: GeneralConsts.gameHardID
    property int cardType: GeneralConsts.gameAllWordID
    property int dealingType: GeneralConsts.gameRandomID

    property int teacher:0  //If you want to modify key, you must modify the key string in Values also
    property int smart:0
    property int invisible:0
    property int gravity:0
    property int shrinker:0
    property int redBull:0

}

