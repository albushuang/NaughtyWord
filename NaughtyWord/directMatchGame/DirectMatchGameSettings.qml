import QtQuick 2.0
import Qt.labs.settings 1.0
import "settingValues.js" as Values
import "../generalJS/generalConstants.js" as GeneralConsts
Settings{
    category: "DirectMatchGame"

//    property int dealingType: GeneralConsts.gameRandomID
    property int cardType: GeneralConsts.gameAllWordID
//    property int questionType: Values.questionWordsID
//    property int answerType: Values.answerImagesID

}

