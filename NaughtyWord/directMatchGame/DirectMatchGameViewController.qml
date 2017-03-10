import QtQuick 2.0
import QtQuick.Window 2.2
import QtMultimedia 5.4
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import AppSettings 0.1
import "qrc:/ScoreView"
import "qrc:/DictLookup"
import "../generalModel"
import "../controllers"
import "qrc:/../UIControls"
import "ModelSettingsInDirectMatchGame.js" as ModelSettings
import "settingValues.js" as Value
import "../generalJS/objectCreate.js" as Create
import "qrc:/NWDialog"
import "../NWUIControls"
import "../generalJS/generalConstants.js" as GeneralConsts
import "../generalJS/tutorialScript.js" as TutScript


Item { id: root
    visible: true
    width: parent.width;  height: parent.height
    state: "game-over"

    property alias choiceButtons: myMainView.choiceButtons
    property ScoreViewController scoreView;
    property string scoreViewQml: "qrc:/ScoreView/ScoreViewController.qml"
    property NWOptions beforeStart
    property string nwOptionsQml: "qrc:/NWUIControls/NWOptions.qml"
    property var practiceOptions
    property bool isPracticeOptions: false   
    property bool quesNoImage: false
    property bool allAnsImageExist: false
    property ReminderWithTimer reminder;

    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property variant tutArrayInThisQML: [UserSettings.tutDirectQuesClickable]
    property NWTutorial tutorial;
    property bool hasTutorial: false


    DragMouseAndHint { id: dragHint
        target: root
        maxX: root.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
        autoRun: false
    }

    DirectMatchGameHost{
        id: gameHost
        onGameOver: {
            root.gameOver()
        }
        onNewQuestionReady: updateQuestionAndChoices();
        onFinishAllPractice:{
            dialog.hasInput = false
            dialog.hasTwoBtns = true
            dialog.callback = gameHost.pullInScheduleAndResumeGame
            dialog.cancelCB = gameHost.gameOver
            dialog.show(qsTr("Great! You've already compeleted today's schedule. Do you want to pull in the schedule?"))
        }

    }

    DirectMatchGameView{
        id:myMainView
        score: gameHost.score
        lifeRatio: gameHost.lifeRatio
        time: (gameHost.timeDuration / 1000).toFixed(1)
        answerType: gameHost.answerType
        questionType: gameHost.questionType
        newsLen: gameHost.studiedNew; reviewsLen: gameHost.studiedReview

        function initComponentWithoutBinding(){
            largerSide = ModelSettings.sizeOfDirectMatchGame[0]
            smallerSide = ModelSettings.sizeOfDirectMatchGame[1]
            flipTime = ModelSettings.shortPenaltyTime/4
        }
    }


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

    // protocol of Scoreview //////////////////
    function repeatGameScoreView() {
        if (UserSettings.allGold < 50) {
            own.watchVideo()
        } else {
            scoreView.destroy();
            UserSettings.allGold -= 50
            own.showMessage(qsTr("-50 gold, %1 gold left").arg(UserSettings.allGold.toString()), root.repeatGame)
            //root.repeatGame();
        }
    }
    // app service
    function backToMenuScoreView() {
        stackView.pop()
    }

    MediaPlayer {
        id: music
        //autoPlay: true
        source: UserSettings.musicON? "qrc:/musics/Rainy_Day_Games.mp3" : ""
        loops: Audio.Infinite
        volume: Qt.platform.os === "android" ? GeneralConsts.androidVolumeAdjust : 1
//        volume: 0 * UserSettings.musicVolume
//        onStatusChanged: {
//            switch(status) { case MediaPlayer.NoMedia: console.log("No Media"); break; case  MediaPlayer.Loading : console.log("Loading"); break; case  MediaPlayer.Buffering : console.log("Buffering"); break; case  MediaPlayer.InvalidMedia : console.log("InvalidMedia"); break; case  MediaPlayer.UnknownStatus  : console.log("UnknownStatus"); break; case  MediaPlayer.Stalled  : console.log("Stalled"); break; }
//        }
//        onError: { console.log("media player error:", errorString);
//            switch(error) { case MediaPlayer.NoError: console.log("no error!"); break; case MediaPlayer.ResourceError: console.log("ResourceError!"); break; case MediaPlayer.FormatError: console.log("FormatError!"); break; case MediaPlayer.AccessDeniedError: console.log("AccessDeniedError!"); break; case MediaPlayer.ServiceMissingError: console.log("ServiceMissingError!"); break; }
//        }
    }

    MediaPlayer {
        id: winSound
        autoPlay: false
        source: UserSettings.soundGameON? "qrc:/musics/Magic Chime.mp3" : ""
        loops: 1
        volume: Qt.platform.os === "android" ? GeneralConsts.androidVolumeAdjust : 1
    }

    NWDialogControl{id: dialog
        width: parent.width*0.618

    }

    Timer { id: waitForGP
        property var obj
        interval: 100
        onTriggered: { obj.destroy() }
    }

    QtObject { id: own
        function updateGold(prop) {
            var info = prop.getHeaderInfoEements()
            for (var i=0;i<info.length;i++) {
                if(info[i].infoTitle == GeneralConsts.txtScore) {
                    var newGold = Math.floor(parseInt(info[i].information)/1000)
                    UserSettings.allGold += newGold
                    own.showMessage(qsTr("+%1 gold, %2 gold left").arg(newGold.toString()).arg(UserSettings.allGold.toString()))
                }
            }
        }

        function watchVideo() {
            var dia = Create.instantComponent(root, "qrc:/GameTOEICBattle/GrandPa.qml",
                                                { width: myMainView.width*0.618,
                                                  adMob: stackView.adMob,
                                                  deleteLater: deleteLater })
            dia.message = qsTr("Lack of gold, watch video to get more?")
        }
        function deleteLater(obj) {
            waitForGP.obj = obj
            waitForGP.start()
        }

        function showMessage(text, fadedCallback) {
            var msg = Create.instantComponent(root,  "qrc:/gvComponent/FadingMessage.qml",
                                                   {width: root.width*0.8, height: root.height*0.1, radius: 10,
                                                    faded: fadedCallback, z:100 } )
            msg.theText.text = text
            msg.color = "#F2F5A9"
            msg.life = 1500
            msg.showAndFade()
        }

        function endOfView() {
            var array = []
            if (beforeStart != null && beforeStart != "undefined") { array.push(beforeStart) }
            if (typeof(scoreView) != "undefined" && scoreView != null) { array.push(scoreView) }
            stackView.popAndDelete(array)
        }
    }

    function start(){
        music.play()
        resetGame()
        root.state ="in-game"
        var result = gameHost.startGame()
        if (result.value == true){
            for(var i = 0; i < myMainView.numOfChoices; i++){
                myMainView.choiceButtons.itemAt(i).fgFrameUrl = "qrc:/pic/cardfront2.png"
            }
            myMainView.questionBlock.fgFrameUrl = "qrc:/pic/cardfront2.png"
            inGameAnimation.start()
            dragHint.hint()
        }else{
            UserSettings.allGold += 50
            own.showMessage(qsTr("+50 gold, %1 gold left").arg(UserSettings.allGold.toString()))

            for(var i = 0; i < myMainView.numOfChoices; i++){
                myMainView.choiceButtons.itemAt(i).fgImageUrl = "qrc:/pic/cardback1.png"
            }

            dialog.hasInput = false
            dialog.hasTwoBtns = false
            dialog.callback = stackView.pop
            root.state = "game-error"
            dialog.show(result.log)
        }
    }

    Timer{id: penaltyTimer; //interval: ModelSettings.wrongPenaltyTime
        onTriggered: {
            myMainView.enableAllCards()
            root.enabled = true
        }
    }

    Timer{id: flipBackTimer; interval: ModelSettings.longPenaltyTime - myMainView.flipTime
        onTriggered: {
            myMainView.questionBlock.flipped = false
            for (var i = 0; i < myMainView.numOfChoices; i++){
                myMainView.choiceButtons.itemAt(i).flipped = false
            }
            gameHost.hideHalfCorrectHint();
        }

    }

    function noImageReminder(){
        var prop = {
            reminderType: UserSettings.remindTypeNoImage,
            remindCancelOption: false,
            reminderDuration: 6000,
        }
        var text = qsTr("Some images of the cards are not available, and are replaced by words and definitions.")
        reminder = Create.instantComponent(root, "qrc:/NWUIControls/ReminderWithTimer.qml", prop)
        reminder.showReminder(text, reminder.enumDirection.left)
        reminder.cycleEndCallback = reminder.destroy;
    }

    function quesNoImageShowType(){
        noImageReminder()
        myMainView.questionBlock.fgShowType = myMainView.questionBlock.showText
        myMainView.questionBlock.bgShowType = myMainView.questionBlock.showText
    }

    function ansNoImageShowType(){
        noImageReminder()
        for (var i = 0; i < myMainView.numOfChoices; i++){
            myMainView.choiceButtons.itemAt(i).fgShowType =  myMainView.choiceButtons.itemAt(i).showText
            myMainView.choiceButtons.itemAt(i).bgShowType =  myMainView.choiceButtons.itemAt(i).showText
        }
    }

    function updateQuesShowType(){
        if( quesNoImage ){
            quesNoImageShowType(); return;
        }
        switch(gameHost.questionType){
        case Value.questionImagesID:
            myMainView.questionBlock.fgShowType = myMainView.questionBlock.showImage
            myMainView.questionBlock.bgShowType = myMainView.questionBlock.showText
            break;
        case Value.questionWordsID:
            myMainView.questionBlock.fgShowType = myMainView.questionBlock.showText
            myMainView.questionBlock.bgShowType = myMainView.questionBlock.showText
            break;
        case Value.questionMeaningsID:
            myMainView.questionBlock.fgShowType = myMainView.questionBlock.showText
            myMainView.questionBlock.bgShowType = myMainView.questionBlock.showText
            break;
        case Value.questionPronounceID:
            myMainView.questionBlock.fgShowType = myMainView.questionBlock.showImage
            myMainView.questionBlock.bgShowType = myMainView.questionBlock.showText
            break;
        }
    }

    function updateAnsShowType(){
        for (var i = 0; i < myMainView.numOfChoices; i++){
            switch(gameHost.answerType){
            case Value.answerImagesID:
                myMainView.choiceButtons.itemAt(i).fgShowType =  myMainView.choiceButtons.itemAt(i).showImage
                myMainView.choiceButtons.itemAt(i).bgShowType =  myMainView.choiceButtons.itemAt(i).showText
                break;
            case Value.answerWordsID:
                myMainView.choiceButtons.itemAt(i).fgShowType =  myMainView.choiceButtons.itemAt(i).showText
                myMainView.choiceButtons.itemAt(i).bgShowType =  myMainView.choiceButtons.itemAt(i).showText
                break;
            case Value.answerMeaningsID:
                myMainView.choiceButtons.itemAt(i).fgShowType =  myMainView.choiceButtons.itemAt(i).showText
                myMainView.choiceButtons.itemAt(i).bgShowType =  myMainView.choiceButtons.itemAt(i).showText
                break;
            }
        }
    }

    function updateAnsShowTypeForHalfWords(){
        for (var i = 0; i < myMainView.numOfChoices; i += 2){
            myMainView.choiceButtons.itemAt(i).fgShowType =  myMainView.choiceButtons.itemAt(i).showImage
            myMainView.choiceButtons.itemAt(i).bgShowType =  myMainView.choiceButtons.itemAt(i).showText
        }
        for (var k = 1; k < myMainView.numOfChoices; k += 2){
            myMainView.choiceButtons.itemAt(k).fgShowType =  myMainView.choiceButtons.itemAt(k).showText
            myMainView.choiceButtons.itemAt(k).bgShowType =  myMainView.choiceButtons.itemAt(k).showText
        }
    }

    function halfWordsHalfCorrectHint(idx){
        var thisChoice = myMainView.choiceButtons.itemAt(idx)
        var point = myMainView.mapFromItem(thisChoice.parent, thisChoice.x, thisChoice.y)
        if( idx % 2 == 0 ){
            myMainView.txthalfCorrectLeftHint.text = "Left\nCorrect"
            myMainView.halfCorrectLeftHint.x = point.x
            myMainView.halfCorrectLeftHint.y = point.y
            myMainView.halfCorrectLeftHint.visible = true;
        }else{
            myMainView.txthalfCorrectRightHint.text = "Right\nCorrect"
            myMainView.halfCorrectRightHint.x = point.x
            myMainView.halfCorrectRightHint.y = point.y
            myMainView.halfCorrectRightHint.visible = true;
        }
    }

    function randomQuestModel(){
        var randomIdx
        var definitionWordIdx = ModelSettings.prDefinitionWord
        var imageWordIdx = definitionWordIdx + ModelSettings.prImageWord
        var wordImageIdx = imageWordIdx + ModelSettings.prWordImage
        randomIdx = Math.random()
        if(randomIdx <= definitionWordIdx ){
            gameHost.questionType = Value.questionMeaningsID
            gameHost.answerType = Value.answerWordsID
        }
        else if(randomIdx > definitionWordIdx && randomIdx <= imageWordIdx){
            gameHost.questionType = Value.questionImagesID
            gameHost.answerType = Value.answerWordsID
        }
        else if(randomIdx > imageWordIdx && randomIdx <= wordImageIdx){
            gameHost.questionType = Value.questionWordsID
            gameHost.answerType = Value.answerImagesID
        }
        else{
            gameHost.questionType = Value.questionWordsID
            gameHost.answerType = Value.answerMeaningsID
        }
    }

    function checkAnsImage(){
        for (var n = 0; n < myMainView.numOfChoices; n++){
            if(gameHost.availableChoices[n].image == "")
                return
        }
        allAnsImageExist = true
        return

    }

    function updateQuestion(){
        quesNoImage = false
        var notes = "", parsedNote = ""
        notes = Qt.atob(gameHost.availableChoices[gameHost.currQuestIdx].notes)
        notes = notesPaser.removeWord(notes, gameHost.availableChoices[gameHost.currQuestIdx].word)
        parsedNote = notesPaser.parseNotes(notes, notesPaser.dsEnum.idNoDict, ModelSettings.maxLines, true)
        if(ModelSettings.directMatchMode == Value.originalID){ randomQuestModel() }
        switch(gameHost.questionType){
        case Value.questionImagesID:
            myMainView.questionBlock.bgTextContent = gameHost.availableChoices[gameHost.currQuestIdx].word
            if(gameHost.availableChoices[gameHost.currQuestIdx].image == ""){
                myMainView.questionBlock.fgTextContent = gameHost.availableChoices[gameHost.currQuestIdx].word;
                quesNoImage = true
//                console.log("question doesn't have any image, word is used instead")
            }
            else{
                myMainView.questionBlock.fgImageUrl = gameHost.getRootPath() + gameHost.availableChoices[gameHost.currQuestIdx].image
                //"image://download/" + gameHost.availableChoices[gameHost.currQuestIdx].id;
            }
            break;
        case Value.questionWordsID:
            myMainView.questionBlock.fgTextContent = gameHost.availableChoices[gameHost.currQuestIdx].word;
            myMainView.questionBlock.bgTextContent = parsedNote
            break;
        case Value.questionMeaningsID:
            myMainView.questionBlock.fgTextContent = parsedNote
            myMainView.questionBlock.bgTextContent = gameHost.availableChoices[gameHost.currQuestIdx].word
            break;
        case Value.questionPronounceID:
            myMainView.questionBlock.fgImageUrl = "qrc:///pictures/icons/speakingTest.jpg" //TODO: no image yet
            myMainView.questionBlock.bgTextContent = parsedNote
            break;
        }
    }

    function updateChoices(){
        allAnsImageExist = false
        var notes = "", parsedNote = ""
        checkAnsImage()
        for (var i = 0; i < myMainView.numOfChoices; i++){
            myMainView.choiceButtons.itemAt(i).flipped = false
            if(ModelSettings.directMatchMode == Value.halfWordsID){
                if( i % 2 == 1 ){gameHost.answerType = Value.answerMeaningsID}
                else if( i % 2 == 0 ){gameHost.answerType = Value.answerImagesID}
            }
            notes = Qt.atob(gameHost.availableChoices[i].notes)
            notes = notesPaser.removeWord(notes, gameHost.availableChoices[i].word)
            parsedNote = notesPaser.parseNotes(notes, notesPaser.dsEnum.idNoDict, ModelSettings.maxLines, true)
            switch(gameHost.answerType){
            case Value.answerImagesID:
                if(allAnsImageExist){
                    myMainView.choiceButtons.itemAt(i).fgImageUrl = gameHost.getRootPath() + gameHost.availableChoices[i].image
                    //"image://download/" + gameHost.availableChoices[i].id
                    myMainView.choiceButtons.itemAt(i).bgTextContent = gameHost.availableChoices[i].word
                }
                else{
                    if( ModelSettings.directMatchMode == Value.originalID ){
//                        console.log("Ans is lack in image, def. is used instead")
                        myMainView.choiceButtons.itemAt(i).fgTextContent = parsedNote
                        myMainView.choiceButtons.itemAt(i).bgTextContent = gameHost.availableChoices[i].word
                    }
                    else{
//                        console.log("Ans is lack in image, word is used instead")
                        myMainView.choiceButtons.itemAt(i).fgTextContent = gameHost.availableChoices[i].word
                        myMainView.choiceButtons.itemAt(i).bgTextContent = parsedNote
                    }
                }
                break;
            case Value.answerWordsID:
                if(ModelSettings.directMatchMode == Value.originalID && quesNoImage){
//                    console.log("answer should be word, but ques is already using word, so answer is no using def.")
                    myMainView.choiceButtons.itemAt(i).fgTextContent = parsedNote
                    myMainView.choiceButtons.itemAt(i).bgTextContent = gameHost.availableChoices[i].word
                }
                else{
                    myMainView.choiceButtons.itemAt(i).fgTextContent = gameHost.availableChoices[i].word
                    myMainView.choiceButtons.itemAt(i).bgTextContent = parsedNote
                }
                break;
            case Value.answerMeaningsID:
                myMainView.choiceButtons.itemAt(i).fgTextContent = parsedNote
                myMainView.choiceButtons.itemAt(i).bgTextContent = gameHost.availableChoices[i].word
                break;
            }
        }
    }

    function updateQuestionAndChoices(){
        updateQuestion()
        updateChoices()
        updateQuesShowType()
        if( allAnsImageExist ){
            switch (ModelSettings.directMatchMode){
            case Value.halfWordsID: updateAnsShowTypeForHalfWords(); break;
            case Value.twiceQuesID: updateAnsShowType(); break;
            case Value.originalID: updateAnsShowType(); break;
            }
        }else ansNoImageShowType();
    }

    function halfWordChoiceButtonClicked(result, index){
         if( result && gameHost.wasWrong ) halfWordsHalfCorrectHint(index)
         if( !result && gameHost.halfCorrect ) halfWordsHalfCorrectHint(index)
         if( !result && !gameHost.halfCorrect ) wrongAnsClicked(index)
    }

    function twiceChoiceButtonClicked(result, index){
        originChoiceButtonClicked(result, index)
    }

    function originChoiceButtonClicked(result, index){
        if( result && gameHost.wasWrong ) myMainView.choiceButtons.itemAt(index).flipped = true
        if( !result ) wrongAnsClicked(index)
    }

    function wrongAnsClicked(index){
        myMainView.choiceButtons.itemAt(index).flipped = !myMainView.choiceButtons.itemAt(index).flipped
        punishForWrongAnswer(true, ModelSettings.wrongPunishColor)
    }

    function tutorialQuesClickable(){
        if(!UserSettings.tutDirectQuesClickable){
            tutorial.tutorialKey = TutScript.tutDirectQuesClickable
            tutorial.focusItem = myMainView.questionBlock
            tutorial.start(600)
            gameHost.stopGameTimer()
        }
    }

    function handleTutorialCompComplete(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked);
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
        }
    }

    function foggyAreaClicked(){} //Do nothing in this case

    function choiceButtonClicked(index) {
        gameHost.timesSameQuesClick ++
        var result = gameHost.handleSelection(index)
        switch (ModelSettings.directMatchMode){
        case Value.halfWordsID: halfWordChoiceButtonClicked(result, index); break;
        case Value.twiceQuesID: twiceChoiceButtonClicked(result, index); break;
        case Value.originalID: originChoiceButtonClicked(result, index); break;
        }
        if (result){
            winSound.stop()
            winSound.play()
            if(gameHost.wasWrong){
                punishForWrongAnswer(false, ModelSettings.correctPunishColor)
                flipBackTimer.start()
            }
        }else{
            if(gameHost.timesSameQuesClick == Value.tutQuesClickableThreshold)
                tutorialQuesClickable()
        }
    }

    function questionClicked(){
        if(hasTutorial){
            hasTutorial = false
            UserSettings.tutDirectQuesClickable = true
            tutorial.destroy();
            gameHost.restartGameTimer()
        }
        myMainView.questionBlock.flipped = !myMainView.questionBlock.flipped
        punishForWrongAnswer(true, "gray")
        gameHost.dontKnowAnswer()
    }

    function gameOver(){
        music.stop()
        if(root.state != "game-over"){
            root.state = "game-over"
            var prop = prepareScoreProperty();
            own.updateGold(prop)
            Create.createComponent(root, scoreViewQml, prop);
        }
    }

    function prepareScoreProperty() {
        var prop = {};
        prop.isPracticeMode = ModelSettings.directMatchMode !=  Value.originalID
        prop.nameOfGame = GeneralConsts.gameNameDirectMatch
        prop.getDBKey = gameHost.getDbIdentifier
        prop.getHeaderInfoEements = gameHost.getHeaderInfoEements
        return prop;
    }

    function constructFinished(result, objId, qmlName){
        if (result && qmlName == scoreViewQml) {
            scoreView = objId;
            scoreView.setScore(gameHost.score, gameHost.timeDuration);
        }
        else if (result && qmlName == nwOptionsQml && !isPracticeOptions) {
            beforeStart = objId;
            beforeStart.btnOneClicked.connect(startClicked)
            beforeStart.btnTwoClicked.connect(practiceClicked)
            beforeStart.btnThreeClicked.connect(settingsClicked)
            beforeStart.btnFourClicked.connect(gameCancelled)
            dragHint.setExtensionMouse(beforeStart.mouseStealer)
        }
        else if (result && qmlName == nwOptionsQml && isPracticeOptions) {
            practiceOptions = objId;
            practiceOptions.btnOneClicked.connect(halfWordsClicked)
            practiceOptions.btnTwoClicked.connect(twiceQuesClicked)
            practiceOptions.btnThreeClicked.connect(practiceCancelled)
        }

    }

    function showOptionsBeforeGameStart(){
        var prop = beforeStartProperty();
        Create.createComponent(root, nwOptionsQml, prop);
    }

    function beforeStartProperty(){
        var prop = {};
        prop.btnNum = 4
        prop.textBtnOne = GeneralConsts.txtStart
        prop.textBtnTwo = qsTr("Practice Mode")
        prop.textBtnThree = GeneralConsts.txtSettings
        prop.textBtnFour = GeneralConsts.txtCancel
        return prop
    }

    function startClicked(){
        if (UserSettings.allGold < 50) {
            own.watchVideo()
            return
        }

        UserSettings.allGold -= 50
        own.showMessage(qsTr("-50 gold, %1 gold left").arg(UserSettings.allGold.toString()), root.start)

        ModelSettings.directMatchMode = Value.originalID
        beforeStart.destroy()
        ModelSettings.dealingType = GeneralConsts.gameRandomID
        //start()
    }

    function practiceClicked(){
        var prop = practiceOptionsProperty();
        isPracticeOptions = true
        beforeStart.visible = false
        Create.createComponent(root, nwOptionsQml, prop);
    }

    function practiceOptionsProperty(){
        var prop = {};
        prop.btnNum = 3
        prop.textBtnOne = qsTr("Half Words & Half Images")
        prop.textBtnTwo = qsTr("Answer Def. & Images in Turn")
        prop.textBtnThree = GeneralConsts.txtCancel
        return prop
    }

    function settingsClicked(){
        var url = "qrc:/directMatchGame/DirectMatchGameSettingViewController.qml"
        NWPleaseWait.callbackAfterForceRedraw = function(){
            var settingController = stackView.switchControl(url,
                                {appSettings: gameHost.directMatchGameSettings}, false, false, true)
            settingController.settingUpdated.connect(root.initComponentWithoutBinding)
            NWPleaseWait.visible = false
        }
        NWPleaseWait.message = ""
        NWPleaseWait.visible = true;
        NWPleaseWait.state = "running";
    }

    function gameCancelled(){
        stackView.pop()
    }

    function halfWordsClicked(){
        ModelSettings.directMatchMode = Value.halfWordsID
        practiceOptions.destroy();
        isPracticeOptions = false
        beforeStart.destroy()
        ModelSettings.dealingType = GeneralConsts.gamePracticeID
        start()
    }

    function twiceQuesClicked(){
        ModelSettings.directMatchMode = Value.twiceQuesID
        practiceOptions.destroy();
        isPracticeOptions = false
        beforeStart.destroy()
        ModelSettings.dealingType = GeneralConsts.gamePracticeID
        start()
    }

    function practiceCancelled(){
        beforeStart.visible = true
        practiceOptions.destroy();
    }

    function punishForWrongAnswer(isShortPenalty, disableColor){
        root.enabled = false
        myMainView.disableAllCards(disableColor)
        penaltyTimer.interval = isShortPenalty ? ModelSettings.shortPenaltyTime : ModelSettings.longPenaltyTime
        penaltyTimer.start()
    }

    function repeatGame(){
        root.state = "in-game"
        start()
    }

    function resetGame(){
        ModelSettings.initTimer(ModelSettings.directMatchMode)
        for (var i = 0; i < choiceButtons.count; i++){
            choiceButtons.itemAt(i).resetBlock("none")
        }
        myMainView.questionBlock.resetBlock("none")
        switch (ModelSettings.directMatchMode){
        case Value.halfWordsID: gameHost.halfWordStatusReset();
            myMainView.isPracticeMode = true; break;
        case Value.twiceQuesID: myMainView.isPracticeMode = true; break;
        case Value.originalID: myMainView.isPracticeMode = false; break;
        }
    }

    states: [
        State {
            name: "in-game"
            PropertyChanges {target: myMainView; enabled: true }
        },
        State {
            name: "game-over"
            PropertyChanges {target: myMainView; enabled: false}
        },
        State {
            name: "game-error"
            PropertyChanges {target: myMainView; visible: true}
            PropertyChanges {target: dialog; visible: true }
        }
    ]

    PropertyAnimation {
        id: inGameAnimation
        target: root
        properties: "opacity"
        from: 0.1; to: 1
        duration: 1000
    }

    function initComponentWithoutBinding(settings){
        gameHost.settingUpdated(settings)
        myMainView.initComponentWithoutBinding()
    }

    Component.onCompleted:{
        gameHost.directMatchGameSettingsReady.connect(initComponentWithoutBinding)
        myMainView.choiceButtons.choiceButtonClickedAt.connect(choiceButtonClicked)
        myMainView.questionBlock.questionClicked.connect(questionClicked)
        showOptionsBeforeGameStart();
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                Create.createComponent(root, tutorialQmlUrl,
                                        {width: root.width, height: root.height},
                                       handleTutorialCompComplete)
                break;
            }
        }
    }

}


