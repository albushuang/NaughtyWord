import QtQuick 2.5
import QtQuick.Window 2.2
import QtMultimedia 5.4
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "../generalModel"
import "ModelSettingsInInsanity.js" as ModelSettings
import "settingValues.js" as Value
import "qrc:/../UIControls"
import "../generalJS/objectCreate.js" as CompCreator
import "../generalJS/tutorialScript.js" as TutScript
import "qrc:/ScoreView"
import "qrc:/NWDialog"
import "../NWUIControls"
import "../generalJS/generalConstants.js" as GeneralConsts



// TODO: add music
Item {id: root
    visible: true
    width: parent.width;  height: parent.height
    state: "game-over"

    property bool playerStart: false
    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property bool hasTutorial: false
    property variant tutArrayInThisQML: [UserSettings.tutInsanityIntro, UserSettings.tutMoveEinstein,
        UserSettings.tutAnswerTheQuestion1, UserSettings.tutPowerUpIntro ]
    property variant tempVariable   //If no tutorial, I don't want to wate this memory space
    property ScoreViewController scoreView;
    property string scoreViewQml: "qrc:/ScoreView/ScoreViewController.qml"
    property NWOptions beforeStart
    property string beforeStartQml: "qrc:/NWUIControls/NWOptions.qml"


    InsanityGameHost{
        id:gameHost
        onGameOver: {
            root.gameOver();
        }
        onNewPowerUp: {
            root.powerUpHandler(powerUp, true);
        }
        onPowerUpEnd: {
            root.powerUpHandler(powerUp, false);
        }
        onNewPowerUpHint: {
            if(!hasTutorial || UserSettings.tutPowerUpIntro){
                myMainView.controllScreen.powerUpAnimation.newPowerUp(powerUp.type, milliSec)
            }else{
                tempVariable = {powerUp: powerUp, milliSec: milliSec}
                poewrUpIntroTutorial()
            }
        }
        onPowerUpEndHint: {
            myMainView.controllScreen.powerUpAnimation.endPowerUp(powerUp.type, milliSec)
        }

    }

    DragMouseAndHint { id: dragHint
        //anchors.fill: myMainView
        anchors {
            top: myMainView.top; bottom: myMainView.bottom;
            left: myMainView.left; right: myMainView.right;
            bottomMargin:  myMainView.controllScreen.height
        }
        target: root
        maxX: root.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: own.endOfView //stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
        autoRun: false
    }

    InsanityView{
        id: myMainView
        score: gameHost.score

        function initComponentWithoutBinding(){//need to postpone initilization after ModelSettings is ready
            objectUnitSizeRatio = ModelSettings.objectUnitSizeRatio
            obsWScale = ModelSettings.obsWScale
            obsHScale = ModelSettings.obsHScale
            mainRoleWScale = ModelSettings.mainRoleWScale
            mainRoleHScale = ModelSettings.mainRoleHScale
            choiceWScale = ModelSettings.choiceWScale
            choiceHScale = ModelSettings.choiceHScale
            obsInitPositionX = ModelSettings.obsInitPositionX
            obsInitPositionY = ModelSettings.obsInitPositionY
            initVelocityScale = ModelSettings.initVelocityScale
            mainRuleBufferDistance = ModelSettings.mainRuleBufferDistance
            choiceBufferDistance = ModelSettings.choiceBufferDistance
            accelerateScale = ModelSettings.accelerateScale
            numberOfChoice = ModelSettings.numberOfChoice
            isImageMode = ModelSettings.gameMode == Value.image
            for(var i = 0; i < ModelSettings.powerUps.length; i++){
                if(ModelSettings.powerUps[i].timer == 0){
                    myMainView.controllScreen.powerUpAnimation.permanentPowerUp.push(ModelSettings.powerUps[i].type);
                }
            }
        }
        onCollideObstacle: {gameHost.collideObstacle()}
        onCollideChoice: {choiceButtonClicked(index)}

        MultiPointTouchArea {
            anchors.fill: myMainView.controllScreen
            MouseArea {id: moveMouseArea
                property real lastX
                property real lastY
                property bool getSmaller: false
                anchors.fill: parent
                onPressed: {
                    lastX = mouse.x
                    lastY = mouse.y
                    if(!playerStart){
                        playerStart = true
                        myMainView.controllScreen.fingerPrint.visible = false
                        start()
                    }
                }
                onPositionChanged: {
                    var mainRole = myMainView.displayScreen.mainRole

                    if(!hasTutorial || (tutorial.tutorialKey != TutScript.tutAnswerTheQuestion1
                                        && tutorial.tutorialKey != TutScript.tutPowerUpIntro)){
                        mainRole.x += 2.3*(mouse.x - lastX)
                        mainRole.y += 2.3*(mouse.y - lastY)
                        keepInScreenBoundaries()
                    }
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
            touchPoints: [
                TouchPoint {},
                TouchPoint {
                    id: point2
                    onPressedChanged:
                        if(pressed == true)
                            myMainView.originDistance = Math.pow(moveMouseArea.lastX-point2.x,2)+Math.pow(moveMouseArea.lastY-point2.y,2)
                        else
                            backToOriginScale();
                    onPreviousXChanged: getSmaller(moveMouseArea.lastX, point2.x, moveMouseArea.lastY, point2.y);
                    onPreviousYChanged: getSmaller(moveMouseArea.lastX, point2.x, moveMouseArea.lastY, point2.y);
                }
            ]
        }
    }

    // protocol of Scoreview //////////////////
    function repeatGameScoreView() {
        if (UserSettings.allGold < 50) {
            own.watchVideo()
        } else {
            waitForGP.obj = scoreView
            waitForGP.start()
            UserSettings.allGold -= 50
            own.showMessage(qsTr("-50 gold, %1 gold left").arg(UserSettings.allGold.toString()))
            root.repeatGame();
        }
    }
    // app service
    function backToMenuScoreView() {
        //stackView.pop()
        own.endOfView()
    }

//TODO : selec new music
    MediaPlayer {
        id: music
        autoPlay: true
        source: UserSettings.musicON ? "qrc:/musics/Kool_Kats.mp3" : ""
        loops: Audio.Infinite
        volume: Qt.platform.os === "android" ? GeneralConsts.androidVolumeAdjust : 1
    }

    MediaPlayer {
        id: winSound
        autoPlay: false
        source: UserSettings.soundGameON ? "qrc:/musics/Magic Chime.mp3" : ""
        loops: 1
        volume: Qt.platform.os === "android" ? GeneralConsts.androidVolumeAdjust : 1
    }

    NWDialogControl {id: errorAlert
        hasInput: false
        hasTwoBtns: false
        width: parent.width*0.618
        callback: stackView.pop
    }

    function start(){
        var result = gameHost.startGame()
        if (result.value == true){
            if(!hasTutorial || UserSettings.tutAnswerTheQuestion1){
                updateQuestionAndChoices()
            }else{
                delayQuestionTimer.restart()
                gameHost.powerUpEnabled = false
            }
            myMainView.displayScreen.obstacelArray.obstacelStartToMove()
        }else{
            root.state = "game-error"
            errorAlert.show(result.log)
        }
        if(hasTutorial && tutorial.tutorialKey == TutScript.tutMoveEinstein){
            tutorial.stop()
            UserSettings.tutMoveEinstein = true
        }
    }

    Timer { id: speechBinding
        interval: 100; repeat: false
        property string theID;
        onTriggered: {
            gameHost.speechClicked(theID);
        }
    }

    function getSmaller(lastX, point2X, lastY, point2Y){
        myMainView.currentDistance = Math.pow(lastX-point2X,2)+Math.pow(lastY-point2Y,2)
        if(myMainView.originDistance>myMainView.currentDistance && gameHost.isSmallerCoolDown){
            myMainView.mainRoleScale = ModelSettings.smallerMainRoleScale;
            smallerTimer.start();
        }
    }

    function backToOriginScale(){
        myMainView.mainRoleScale = ModelSettings.originMainRoleScale;
        gameHost.isSmallerCoolDown = false
        smallerCoolDownTimer.start();
        keepInScreenBoundaries();
    }

    function keepInScreenBoundaries(){
        var mainRole = myMainView.displayScreen.mainRole
        mainRole.x = Math.max(0, Math.min(mainRole.x,
                                 myMainView.displayScreen.width - myMainView.displayScreen.mainRole.width))
        mainRole.y = Math.max(0, Math.min(mainRole.y,
                                 myMainView.displayScreen.height - myMainView.displayScreen.mainRole.height))
    }

    Timer{
        id: smallerTimer
        interval: ModelSettings.smallerTimeLimit
        onTriggered: backToOriginScale()
    }

    Timer{
        id:smallerCoolDownTimer
        interval: ModelSettings.smallerTimeCoolDown
        onTriggered: gameHost.isSmallerCoolDown = true
    }

    function updateQuestionAndChoicesForImage() {
        speechBinding.theID = gameHost.availableChoices[gameHost.currQuestIdx].speech;
        speechBinding.start();
        myMainView.word = gameHost.availableChoices[gameHost.currQuestIdx].word;
        for (var i = 0; i < myMainView.numberOfChoice; i++){
            myMainView.displayScreen.choiceArray.itemAt(i).source = gameHost.getRootPath() + gameHost.availableChoices[i].image
                    //"image://download/" + gameHost.availableChoices[i].id;
        }
    }

    function updateQuestionAndChoicesForSpelling() {
        if(gameHost.currentAlphabetIdx == 0){
            gameHost.speechClicked(gameHost.currQuestion.id);
            myMainView.imageForSpellingMode.source =
                    gameHost.getRootPath() + gameHost.currQuestion.image
                    //"image://download/" + gameHost.currQuestion.id;
        }

        for (var i = 0; i < myMainView.numberOfChoice; i++){
            myMainView.displayScreen.choiceArray.itemAt(i).letter = gameHost.availableChoices[i].toUpperCase();
        }
    }

    function updateQuestionAndChoices(){
        myMainView.displayScreen.choiceArray.assignChoicesToRandomPosition();
        checkPowerUp();
        switch(gameHost.insanitySettings.gameType){
        case Value.image:
            updateQuestionAndChoicesForImage();
            break;
        case Value.spelling:
            updateQuestionAndChoicesForSpelling();
            break;
        }

    }

    function choiceButtonClicked(index) {
        var result = gameHost.handleSelection(index)
        switch(gameHost.insanitySettings.gameType){
        case Value.image:
                updateQuestionAndChoices()
            break;
        case Value.spelling:
            if(result){
                myMainView.word = gameHost.currQuestion.word.substr(0, gameHost.currentAlphabetIdx)
                updateQuestionAndChoices()
            }else{
                myMainView.displayScreen.choiceArray.removeChoice(myMainView.displayScreen.choiceArray.itemAt(index))
            }
            break;
        }
        if (result){
            winSound.stop()
            winSound.play()
        }
        myMainView.bonusView.bonus = (result? "+": "") +
                Math.round(gameHost.correctCount*gameHost.scoreMultiplexer) * (result? 1 : -1)
        myMainView.bonusView.scaleAnimaiton.start()
    }

    function powerUpHandler(powerUp, enabling){
        switch(powerUp.type){
        case Value.teacher:
            if(enabling)
            {
                myMainView.displayScreen.choiceArray.disableAllHintAnimation();
                myMainView.displayScreen.choiceArray.enableHintAnimationBy(gameHost.currQuestIdx);
            }else{
                myMainView.displayScreen.choiceArray.disableAllHintAnimation();
            }
            break;
        case Value.smart:
            if(enabling)
            {
                myMainView.displayScreen.choiceArray.disableAllCollisionWithMainRole();
                myMainView.displayScreen.choiceArray.enableCollisionWithMainRoleBy(gameHost.currQuestIdx);
            }else{
                myMainView.displayScreen.choiceArray.enableAllCollisionWithMainRole();
            }
            break;
        case Value.invisible:
            if(enabling)
            {
                myMainView.displayScreen.mainRole.disableCollisionWithObstacle();
            }else{
                myMainView.displayScreen.mainRole.enableCollisionWithObstacle();
            }
            break;
        case Value.gravity:
            if(enabling){
                myMainView.displayScreen.obstacelArray.modifyVelocityBy(powerUp.effect);
            }else{
                console.assert(false, "gravity cannot be disabled")
            }

            break;
        case Value.shrinker:
            if(enabling){
                myMainView.displayScreen.obstacelArray.modifySizeBy(powerUp.effect);
            }else{
                myMainView.displayScreen.obstacelArray.modifySizeBy(1/powerUp.effect);
            }
            break;
        }
    }

    function checkPowerUp(){
        for(var i = 0; i < gameHost.ongoingPowerUps.length; i++){
            if(gameHost.ongoingPowerUps[i].type == Value.teacher || gameHost.ongoingPowerUps[i].type == Value.smart){
                powerUpHandler(gameHost.ongoingPowerUps[i], true);
            }
        }
    }

    function gameOver(){
        //root.state = "game-over" // buggy in iphone, don't know why
        moveMouseArea.enabled = false
        myMainView.displayScreen.obstacelArray.stopAll()
        myMainView.displayScreen.mainRoleBody.linearVelocity = Qt.point(0,0)
        delayQuestionTimer.stop()
        if (tutorial != null ) { tutorial.destroy() }
        var prop = prepareScoreProperty();
        own.updateGold(prop)
        CompCreator.createComponent(root, scoreViewQml, prop);
    }

    function prepareScoreProperty() {
        var prop = {};
        prop.nameOfGame = GeneralConsts.gameNameInsanity
        prop.getDBKey = gameHost.getDbIdentifier
        prop.getHeaderInfoEements = gameHost.getHeaderInfoEements
        return prop;
    }

    function repeatGame(){
        resetGame()
        //root.state = "in-game" // buggy in iphone, don't know why
        moveMouseArea.enabled = true
        own.checkTutor()
    }

    function resetGame(){
        myMainView.initView()
        playerStart = false
        gameHost.resetGame()
    }

    Timer{id: delayQuestionTimer; interval: 8000;
        onTriggered: {
            updateQuestionAndChoices()
            answerQuestionTutorial()
        }
    }

    function constructFinished(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            hasTutorial = true
            tutorial = objId
            tutorial.spacing = -10
            tutorial.foggyAreaClicked.connect(foggyAreaClicked)
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
            tutorial.indicator = null
            if(!UserSettings.tutInsanityIntro){
                insanityIntroTutorial()
            }else if(!UserSettings.tutMoveEinstein){
                moveEinsteinTutorial()
            }
        }
        else if (result && qmlName == scoreViewQml) {
            scoreView = objId;
            scoreView.setScore(gameHost.score, gameHost.timeDuration);
        }
        else if (result && qmlName == beforeStartQml) {
            beforeStart = objId;
            beforeStart.btnOneClicked.connect(startClicked)
            beforeStart.btnTwoClicked.connect(settingsClicked)
            beforeStart.btnThreeClicked.connect(storeClicked)
            beforeStart.btnFourClicked.connect(gameCancelled)
            dragHint.setExtensionMouse(beforeStart.mouseStealer)
        }
    }

    function showOptionsBeforeGameStart(){
        var prop = beforeStartProperty();
        CompCreator.createComponent(root, beforeStartQml, prop);
    }

    function beforeStartProperty(){
        var prop = {};
        prop.btnNum = 4
        prop.textBtnOne = GeneralConsts.txtStart
        prop.textBtnTwo = GeneralConsts.txtSettings
        prop.textBtnThree = GeneralConsts.txtStore
        prop.textBtnFour = GeneralConsts.txtCancel
        return prop
    }

    function startClicked(){
        if (UserSettings.allGold < 50) {
            own.watchVideo()
        } else {
            beforeStart.destroy()
            UserSettings.allGold -= 50
            own.showMessage(qsTr("-50 gold, %1 gold left").arg(UserSettings.allGold.toString()))
            own.checkTutor()
            dragHint.hint()
            resetGame()
        }
    }

    function settingsClicked(){
        var url = "qrc:/GameInsanity/InsanitySettingViewController.qml"
        NWPleaseWait.callbackAfterForceRedraw = function(){
            var settingController = stackView.switchControl(url,
                                {appSettings: gameHost.insanitySettings}, false, false, true)
            settingController.settingUpdated.connect(root.initComponentWithoutBinding)
            NWPleaseWait.visible = false
        }
        NWPleaseWait.message = ""
        NWPleaseWait.visible = true;
        NWPleaseWait.state = "running";
    }

    function storeClicked(){
        var url = "qrc:/GameInsanity/InsanityStore.qml"
        stackView.vtSwitchControl(url, {insanitySettings: gameHost.insanitySettings}, false, false, true)
    }

    function gameCancelled(){
        own.endOfView()
        //stackView.pop()
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
                    var newGold = Math.floor(parseInt(info[i].information)/100)
                    UserSettings.allGold += newGold
                    own.showMessage(qsTr("+%1 gold, %2 gold left").arg(newGold.toString()).arg(UserSettings.allGold.toString()))
                }
            }
        }

        function checkTutor() {
            for(var i = 0; i < tutArrayInThisQML.length; i++){
                if(!tutArrayInThisQML[i]){
                    CompCreator.createComponent(root, tutorialQmlUrl,
                                                {width: root.width, height: root.height})
                    break;
                }
            }
        }

        function watchVideo() {
            var dia = CompCreator.instantComponent(root, "qrc:/GameTOEICBattle/GrandPa.qml",
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
            var msg = CompCreator.instantComponent(root,  "qrc:/gvComponent/FadingMessage.qml",
                                                   {width: root.width*0.8, height: root.height*0.1, radius: 10,
                                                   faded: fadedCallback, z: 100} )
            msg.theText.text = text
                    //qsTr("-50 gold, %1 gold left").arg(UserSettings.allGold.toString())
            msg.color = "#F2F5A9"
            msg.life = 1500
            msg.show()
            msg.fade()
        }

        function endOfView() {
            var array = []
            if (beforeStart != null && beforeStart != "undefined") { array.push(beforeStart) }
            if (typeof(scoreView) != "undefined" && scoreView != null) { array.push(scoreView) }
            stackView.popAndDelete(array)
        }
    }

    function insanityIntroTutorial(){
        tutorial.tutorialKey = TutScript.tutInsanityIntro
        tutorial.focusItem = myMainView.displayScreen
        tutorial.focusFrameEnabled = false
        tutorial.start()
    }

    function moveEinsteinTutorial(){
        if(!UserSettings.tutMoveEinstein){
            tutorial.tutorialKey = TutScript.tutMoveEinstein
            tutorial.focusItem = myMainView.controllScreen
            tutorial.focusFrameEnabled = false
            tutorial.start()
        }
    }

    function answerQuestionTutorial(){
        if(!UserSettings.tutAnswerTheQuestion1){
            tutorial.tutorialKey = TutScript.tutAnswerTheQuestion1
            tutorial.focusItem = myMainView.displayScreen.choiceArray.itemAt(gameHost.currQuestIdx).choiceBox
            tutorial.start()
            myMainView.displayScreen.obstacelArray.stopAll()
            gameHost.pauseGame()
        }
    }

    function poewrUpIntroTutorial(){
        if(!UserSettings.tutPowerUpIntro){
            tutorial.tutorialKey = TutScript.tutPowerUpIntro
            tutorial.focusItem = myMainView.controllScreen.powerUpAnimation.randomImg
            tutorial.start()
            myMainView.controllScreen.powerUpAnimation.randomImg.randPowerUp = tempVariable.powerUp.type  //Show powerUp image without animetion
            myMainView.controllScreen.powerUpAnimation.randomImg.opacity = 1
            myMainView.displayScreen.obstacelArray.stopAll()
            gameHost.powerUpEnabled = false
            gameHost.pauseGame()
        }
    }

    function foggyAreaClicked(){
        if(tutorial.tutorialKey == TutScript.tutInsanityIntro){
            tutorial.stop()
            UserSettings.tutInsanityIntro = true
            moveEinsteinTutorial()
        }else if(tutorial.tutorialKey == TutScript.tutAnswerTheQuestion1){
            tutorial.tutorialKey = TutScript.tutAnswerTheQuestion2
            tutorial.gText.text = TutScript.getScriptObj(tutorial.tutorialKey).guideText
            UserSettings.tutAnswerTheQuestion1 = true
        }else if(tutorial.tutorialKey == TutScript.tutAnswerTheQuestion2 ||
                 tutorial.tutorialKey == TutScript.tutPowerUpIntro){
            if(tutorial.tutorialKey == TutScript.tutPowerUpIntro){
                UserSettings.tutPowerUpIntro = true
                myMainView.controllScreen.powerUpAnimation.newPowerUp(tempVariable.powerUp.type, tempVariable.milliSec)
            }
            tutorial.stop()
            myMainView.displayScreen.obstacelArray.resume()
            gameHost.powerUpEnabled = true
            gameHost.resumeGame()
        }
    }

    states: [
        State {
            name: "in-game"
            PropertyChanges {target: myMainView; enabled: true }
        },
        State {
            name: "game-over"
            PropertyChanges {target: myMainView; enabled: false }
        },
        State {
            name: "game-error"
            PropertyChanges {target: myMainView; visible: true }
            PropertyChanges {target: errorAlert; visible: true }
        }
    ]
    function initComponentWithoutBinding(settings){
        gameHost.settingUpdated(settings)
        myMainView.initComponentWithoutBinding()
        //resetGame()
    }

    Component.onCompleted: {
        gameHost.insanitySettingsReady.connect(initComponentWithoutBinding)
        showOptionsBeforeGameStart();
    }
    Component.onDestruction: {
        if(tutorial!=null) { tutorial.destroy() }
    }
}


