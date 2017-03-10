import QtQuick 2.0
import "../generalModel"
import "settingValues.js" as Value
import "../generalJS/generalConstants.js" as GeneralConsts

NWRadioBtnSettings {id: root
    infoModelArray: [
//        infoModel0,
//        infoModel1,
        infoModel0,
//        infoModel1
    ]
    displayTextArr: [
//        Value.stringQuestionType,
//        Value.stringAnswerType,
        GeneralConsts.stringCardType,
//        GeneralConsts.stringDealingType
    ]
    //:Question(Answer) Mode is for users to select the contents of the questions(answers);
    headerInfo: [
//        Value.txtQuestionType,
//        Value.txtAnswerType,
        GeneralConsts.txtGameQuestionPool//,
//        GeneralConsts.txtGameDeallingType
    ]
    settings: [
//        appSettings.questionType,
//        appSettings.answerType,
        appSettings.cardType,
//        appSettings.dealingType
    ]
    property variant appSettings
    viewController: stackView

    signal settingUpdated(variant appSettings)
//we move game settings after opening game, to prevent two setting instances

    function markForFutureUsage(){
//    questionTypeSettings
//    ListModel { id: infoModel0
//        Component.onCompleted: {//group will be automatically assigned later
//            append({id: Value.questionWordsID, group: -1 })
//            append({id: Value.questionImagesID, group: -1 })
//            append({id: Value.questionMeaningsID, group: -1 })
//            append({id: Value.questionPronounceID, group: -1 })
//        }
//    }

//    answerTypeSettings
//    ListModel { id: infoModel1
//        Component.onCompleted: {//group will be automatically assigned later
//            append({id: Value.answerWordsID, group: -1 })
//            append({id: Value.answerImagesID, group: -1 })
//            append({id: Value.answerMeaningsID, group: -1 })
//        }
//    }

//    onRadioButtonClicked: {
//        handleConflict(group)
//    }
//    function handleConflict(userClickedGroup){
////TODO 排除掉一些不太合理的模式: for ex, 發音&單字  圖片&字義   字義&圖片
//        if (settings[0] == settings[1]) {
//            var changedGroup = userClickedGroup == 0? 1 : 0 //If user clicked group0 button, then we change group1 choices
//            var changedGroupModel = userClickedGroup == 0 ? infoModel1: infoModel0
//            for(var i = 0; i < changedGroupModel.count; i++){
//                if(settings[changedGroup] != changedGroupModel.get(i).id){
//                    settings[changedGroup] = changedGroupModel.get(i).id
//                    //the property binding of radioBtn.checked is replaced because of mouse clicked.
//                    //Only set settings[x] = xxx is not enough
//                    listViewArray.itemAt(changedGroup).choiceListView.currentIndex = i
//                    listViewArray.itemAt(changedGroup).choiceListView.currentItem.radioBtn.checked = true
//                    break;
//                }
//            }
//        }
//    }
}

//    cardType
    ListModel { id: infoModel0
        Component.onCompleted: {//group will be automatically assigned later
            append({id: GeneralConsts.gameAllWordID, group: -1 })
            append({id: GeneralConsts.gameTodayPracticedID, group: -1 })
            append({id: GeneralConsts.gameAllPracticedID, group: -1 })
           }
        }

//    dealingType
//    ListModel { id: infoModel1
//        Component.onCompleted: {//group will be automatically assigned later
//            append({id: GeneralConsts.gameRandomID, group: -1 })
//            append({id: GeneralConsts.gamePracticeID, group: -1 })
//        }
//    }

    Component.onDestruction: {
//        appSettings.questionType = settings[0]
//        appSettings.answerType = settings[1]
        appSettings.cardType = settings[0]
//        appSettings.dealingType = settings[1]

        settingUpdated(appSettings)
    }
}



