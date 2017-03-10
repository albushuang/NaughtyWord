import QtQuick 2.0
import QtQuick.Window 2.2
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import "../generalModel"
import "qrc:/../UIControls"
import "qrc:/NWUIControls"
import "qrc:/DictLookup"
import "ModelSettingsInLingoPractice.js" as ModelSettings
import "ViewSettingsInLingoPractice.js" as ViewConst
import "../generalJS/objectCreate.js" as CompCreator
import "../generalJS/tutorialScript.js" as TutScript
import "SuperMemoAlgorithm.js" as Algor
import "qrc:/NWDialog"

Item{id: lingoPracticeViewController
    width: parent.width;  height: parent.height
    state: "in-game"
    property bool showingFront
    property bool result:false
    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property variant tutArrayInThisQML: [UserSettings.tutHowToUseAnki1, UserSettings.tutHowToUseAnki2,
        UserSettings.tutHowToUseAnki3, UserSettings.tutHowToUseAnki4 ]
    property bool hasTutorial: false

    Sim2Tradition { id: langConverter
        function doNothing(cc) {return cc}
    }

    NotesPaser{id: notesPaser
        langConverter: langConverter
        langConvert: {
            var ret = langConverter.doNothing
            switch(appSettings.readSetting("NaughtyWord/Language")) {
            case "sc": ret = langConverter.simplify; break
            //case "tc": ret = langConverter.traditionalized; break
            case "tc": ret = langConverter.doNothing; break
            }
            return ret
        }
    }

    LingoPracticeModel{
        id: practiceHost
        onPracticingOver: {
            var practiceOverResult = practiceOver()
            if(practiceOverResult.value)
                practiceOverView.show(practiceOverResult.log)
            lingoPracticeViewController.state = "game-over"
        }
        onLockFound: {
            console.log("width & height", width, height)
            var p = lingoPracticeViewController.parent
            var message = CompCreator.instantComponent(lingoPracticeViewController,
                            "qrc:/gvComponent/FadingMessage.qml",
                            {width: p.width*0.8, height: p.height*0.2} )
            message.theText.text = qsTr("%1 cards locked! Due to TOEIC Battle stage locked.").arg(locked)
            message.theText.color = "orange"
            message.life = 4000
            message.show()
        }
    }

    DragMouseAndHint {
        target: lingoPracticeViewController
        maxX: lingoPracticeViewController.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "right"
    }
    LingoPracticeView{
        id:myMainView

        newsLen: practiceHost.newCardsLen
        learnsLen: practiceHost.learnCardsLen
        reviewsLen: practiceHost.reviewCardsLen
        focus: true

        function initComponentWithoutBinding(){}

//        onFocusChanged:{  //Dont know why activeFocus is stolen
//            console.log("1activeFocus: " + activeFocus)
//            if(focus == false){
//                focus = true
//                console.log("2activeFocus: " + activeFocus)
//            }
//        }

        answerGesture.onPressAndHold: {
            if(hasTutorial && tutorial.tutorialKey == TutScript.tutHowToUseAnki2){
                tutorial.stop()
            }
            handleTutorial3()
        }

        Keys.onPressed: {
            keyBoardHandler(event)
        }
    }

    NWDialogControl{ id: practiceOverView
        hasInput: false
        hasTwoBtns: false
        width: parent.width*0.618
        callback: stackView.pop
    }
    NWDialogControl{ id: alreadyPracticed
        hasTwoBtns: true
        hasInput: false
        width: parent.width*0.618
        callback: function(t) {
            lingoPracticeViewController.state = "in-game"
            practiceHost.pullInPractice()
            start()
        }
        cancelCB: stackView.pop
    }



    NWDialogControl{id: errorAlert
        hasInput: false
        hasTwoBtns: false
        width: parent.width*0.618
        callback: stackView.pop
    }

    function start(){
        var checkResult = practiceHost.checkNumOfCards();
        if(checkResult.value){
            result = practiceHost.startPracticing()
            if(result){
                fillFrontData()
            }else{
                var scheduleCompeleted = practiceHost.scheduleAleadyCompeleted()
                if(scheduleCompeleted.value)
                    alreadyPracticed.show(scheduleCompeleted.log)
                lingoPracticeViewController.state = "game-over"
            }
        }
        else{
            errorAlert.show(checkResult.log)
            lingoPracticeViewController.state = "game-error"
        }

    }

    function fillFrontData(){
        showingFront = true
        myMainView.questionBlock.word = practiceHost.currCard.word
        myMainView.questionBlock.phonicAlphabet = Qt.atob(practiceHost.currCard.pa)
        myMainView.questionBlock.imageUrl = ""
        myMainView.questionBlock.translation = ""
        myMainView.numberOfChoice = 1
        myMainView.choiceButtons.itemAt(0).textContent = "Show Answer"
        myMainView.choiceButtons.focusIndex = 0
        myMainView.gestureArrowHint.visible = false
        playSpeech()
    }

    function fillBackData(){        
        myMainView.questionBlock.imageUrl = practiceHost.getPicture()
                //"image://download/" + practiceHost.currCard.id
        var note = Qt.atob(practiceHost.currCard.notes)
        note = notesPaser.removeWord(note, practiceHost.currCard.word)
        myMainView.questionBlock.translation = note
                //notesPaser.parseNotes(note, notesPaser.dsEnum.idNoDict, ModelSettings.maxLines, false)
        switch(practiceHost.currCard.status){
        case 0:
        case 1:
            myMainView.numberOfChoice = 3
            myMainView.choiceButtons.itemAt(0).textContent = ViewConst.disAgain//"Again"
            myMainView.choiceButtons.itemAt(1).textContent = ViewConst.disGood //"Good"
            myMainView.choiceButtons.itemAt(2).textContent = ViewConst.disEasy //"Easy"
            myMainView.choiceButtons.itemAt(0).easiness = Algor.idAgain
            myMainView.choiceButtons.itemAt(1).easiness = Algor.idGood
            myMainView.choiceButtons.itemAt(2).easiness = Algor.idEasy
            myMainView.choiceButtons.focusIndex = 1
            myMainView.gestureArrowHint.visible = true
            myMainView.gestureArrowHint.arrows.itemAt(0).direction = "down"
            myMainView.gestureArrowHint.arrows.itemAt(1).direction = "right"
            myMainView.gestureArrowHint.arrows.itemAt(2).direction = "up"
            break;
        case 2:
            myMainView.numberOfChoice = 4
            myMainView.choiceButtons.itemAt(0).textContent = ViewConst.disAgain//"Again"
            myMainView.choiceButtons.itemAt(1).textContent = ViewConst.disHard //"Hard"
            myMainView.choiceButtons.itemAt(2).textContent = ViewConst.disGood //"Good"
            myMainView.choiceButtons.itemAt(3).textContent = ViewConst.disEasy //"Easy"
            myMainView.choiceButtons.itemAt(0).easiness = Algor.idAgain
            myMainView.choiceButtons.itemAt(1).easiness = Algor.idHard
            myMainView.choiceButtons.itemAt(2).easiness = Algor.idGood
            myMainView.choiceButtons.itemAt(3).easiness = Algor.idEasy
            myMainView.choiceButtons.focusIndex = 2
            myMainView.gestureArrowHint.visible = true
            myMainView.gestureArrowHint.arrows.itemAt(0).direction = "down"
            myMainView.gestureArrowHint.arrows.itemAt(1).direction = "left"
            myMainView.gestureArrowHint.arrows.itemAt(2).direction = "right"
            myMainView.gestureArrowHint.arrows.itemAt(3).direction = "up"
            break;
        }
    }

    function choiceButtonClicked(easiness){
        if(showingFront){
            showingFront = false
            fillBackData()
            if(hasTutorial && tutorial.tutorialKey == TutScript.tutHowToUseAnki1){
                tutorial.stop()
            }
            handleTutorial2()
        }else{
            practiceHost.userClicks(easiness)
            showingFront = true

            if(hasTutorial && tutorial.tutorialKey == TutScript.tutHowToUseAnki3){
                tutorial.stop()
            }
            if(!UserSettings.tutHowToUseAnki4){
                handleTutorial4()
            }
            else{
                fillFrontData()
            }
        }
    }

    function keyBoardHandler(event){
        if (event.key == Qt.Key_Space) {
            if(showingFront){
                choiceButtonClicked(0)
            }else{
                if(numberOfChoice == 3){
                    choiceButtonClicked(1)
                }else{
                    choiceButtonClicked(2)
                }
            }
        }else if(event.key == Qt.Key_1 || event.key == Qt.Key_2 || event.key == Qt.Key_3 ||
                 (event.key == Qt.Key_4 && practiceHost.currCard.status == 2)){
            if(showingFront){
                choiceButtonClicked(0)
            }else{
                choiceButtonClicked((event.key.valueOf() & 0x07) - 1)
            }
        }
    }

    function swipedHandler(direction){
        var easiness = -1
        if(!(hasTutorial && tutorial.tutorialKey == TutScript.tutHowToUseAnki2)){
            if(!showingFront){
                switch(direction){
                case "right": //Good
                    easiness = Algor.idGood
                    break
                case "left": //Hard or nothing
                    easiness = myMainView.numberOfChoice == 4 ? Algor.idHard : -1
                    break
                case "up":  //Easy
                    easiness = Algor.idEasy
                    break
                case "down":  //Again
                    easiness = Algor.idAgain
                    break
                }
                if(easiness != -1){
                    choiceButtonClicked(easiness)
                }
            }
        }
    }

    function tappedHandler(){
        if(showingFront){
            choiceButtonClicked(0)
        }
    }

    function playSpeech(){
        practiceHost.speechClicked(practiceHost.currCard.speech)
    }

    function constructFinished(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked);
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
            if(!UserSettings.tutHowToUseAnki1){
                tutorial.tutorialKey = TutScript.tutHowToUseAnki1
                tutorial.focusItem = myMainView.wordArea
                tutorial.focusFrameEnabled = false
                tutorial.foggyEffect = false
                tutorial.start(600)
                UserSettings.tutHowToUseAnki1 = true
            }
        }
    }

    function handleTutorial2(){
        if(!UserSettings.tutHowToUseAnki2){
            tutorial.tutorialKey = TutScript.tutHowToUseAnki2
            tutorial.focusItem = myMainView.questionImageArea
            tutorial.imageRatio = 0.95
            tutorial.focusFrameEnabled = false
            tutorial.foggyEffect = false
            tutorial.start(600)
            UserSettings.tutHowToUseAnki2 = true
        }
    }

    function handleTutorial3(){
        if(!UserSettings.tutHowToUseAnki3){
            tutorial.tutorialKey = TutScript.tutHowToUseAnki3
            tutorial.focusFrameEnabled = false
            tutorial.foggyEffect = false
            tutorial.focusItem = myMainView.questionImageArea
            tutorial.imageRatio = 0.95
            tutorial.start(300)
            UserSettings.tutHowToUseAnki3 = true
        }        
    }

    function handleTutorial4(){
        tutorial.tutorialKey = TutScript.tutHowToUseAnki4
        tutorial.focusFrameEnabled = false
        tutorial.focusItem = myMainView.wordArea
        tutorial.start()
        UserSettings.tutHowToUseAnki4 = true
    }

    function foggyAreaClicked(){
        if(hasTutorial && tutorial.isOnGoing(TutScript.tutHowToUseAnki4)){
            tutorial.stop()
            fillFrontData()
        }      
    }

    states: [
        State {
            name: "in-game"
            PropertyChanges{target: myMainView; enabled: true }
            PropertyChanges{target: practiceOverView; visible: false }
        },
        State {
            name: "game-over"
            PropertyChanges{target: myMainView; enabled: false}
            PropertyChanges{target: practiceOverView; visible: true }
        },
        State {
            name: "game-error"
            PropertyChanges {target: myMainView; visible: true}
            PropertyChanges {target: errorAlert; visible: true }
        }
    ]

    function initComponentWithoutBinding(settings){
        ModelSettings.init(settings)
        myMainView.initComponentWithoutBinding()
        start()
    }
    Component.onCompleted:{
        practiceHost.lingoPracticeSettingsReady.connect(initComponentWithoutBinding)
        myMainView.choiceButtons.choiceButtonClickedAt.connect(choiceButtonClicked)
        myMainView.answerGesture.swiped.connect(swipedHandler)
        myMainView.answerGesture.tapped.connect(tappedHandler)
        myMainView.phonicAlphabetArea.speechClicked.connect(playSpeech)
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                CompCreator.createComponent(lingoPracticeViewController, tutorialQmlUrl,
                                        {width: lingoPracticeViewController.width, height: lingoPracticeViewController.height})
                break;
            }
        }
    }
    Component.onDestruction: {
        if(tutorial!=null) { tutorial.destroy() }
    }
}
