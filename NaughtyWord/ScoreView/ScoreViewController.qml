import QtQuick 2.5
import QtQuick.Window 2.2
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "gameDbHandler.js" as DbHandler
import "gameScoreServer.js" as Server
import "scoreConsts.js" as Consts
import "../generalJS/generalConstants.js" as GeneralConsts
import "qrc:/generalModel"

// should assign gameName
// parent should control life cycle of scoreview: repeatGameScoreView and backToMenuScoreView
/* callback function:
    getDBKey (game dependent)
    getHeaderInfoEements()  //return element format: {infoTitle: xxx, information: xxx }
*/
// update score and timeDuratoin at end of game
// make sure score is assigned after getDBKey
Item { id: controller
    property var getDBKey
    property var getHeaderInfoEements
    property string nameOfGame
    property bool showSrvScore: true
    property bool isPracticeMode
    signal getSrvRecords()
    anchors.centerIn: parent
    ScoreView { id: view
        anchors.fill: parent
        protocolDelegator: controller
        tableHeaderHeight: controller.parent.width*0.9*76/663;
        viewType: Consts.idLocal
        gameName: nameOfGame  
        showSrvScore: controller.showSrvScore
        isPracticeMode: isPracticeMode
    }

    QtObject { id: own
        property real timeDuration
        property int score
        property var serverRecords
        property bool isServerAlive
    }

    Timer{id: retryTimer; repeat: true; interval: 3000
        onTriggered:{
            Server.getWholeRecords(getDBKey(), saveServerRecords)
        }

    }

    function repeatGameClicked() {
        parent.repeatGameScoreView();
    }
    function backToMenuClicked() {
        parent.backToMenuScoreView();
    }

    function enterClicked(name) {
        UserSettings.lastInputName = name

        /*Notice! update local DB first, and then update server DB*/
        DbHandler.updateHighScore(name, own.score, own.timeDuration, getDBKey())
        if(showSrvScore && own.isServerAlive){
            updateScoreToServer()
        }

        view.needUserTypeName = false;
        fillHighScoreModel(getHighScores(view.viewType))
    }

    function pageClicked(pageId){
        view.viewType = pageId
        fillHighScoreModel(getHighScores(pageId))
        if(pageId == Consts.idGlobal && !own.isServerAlive){
            NWPleaseWait.setAsDefault(controller.parent)
            NWPleaseWait.visible = true; NWPleaseWait.state = "running";
            Server.getWholeRecords(getDBKey(), saveServerRecords)
            retryTimer.start()
        }else{
            NWPleaseWait.visible = false
        }
    }

    function getHighScores(scoreType){
        if(scoreType == Consts.idLocal){
            return DbHandler.getHighScores(controller.getDBKey())
        }else if(scoreType == Consts.idGlobal && typeof(own.serverRecords) != "undefined"){
            return own.serverRecords
        }else{
            return []
        }

    }

    function isNewRecord(score) {
        return DbHandler.isNewRecordBy(score, controller.getDBKey());
    }

    function prepareNewRecordView() {
        view.updateGameInfo(getHeaderInfoEements());
        if(!isPracticeMode){
            if(isNewRecord(own.score)) {
                view.nameInput.inputText.text = UserSettings.lastInputName;
                view.nameInput.inputText.selectAll();
                view.needUserTypeName = true;

                if(UserSettings.lastInputName == GeneralConsts.companyName){
                    view.nameInput.inputText.focus = false
                    view.nameInput.inputText.forceActiveFocus();
                }
            }
            fillHighScoreModel(getHighScores(view.viewType));
        }
    }

    function fillHighScoreModel(highScores){   
        view.infoModel.clear();
        for (var i = 0; i < highScores.length; i++){
            var title = typeof(highScores[i]["title"]) != "undefined" ? highScores[i]["title"] : ""
            view.infoModel.append({ "name": highScores[i]["name"], "studyTitle": title,
                     "score": highScores[i]["score"], "time": highScores[i]["time"] } )
        }
    }
    function updateWindowsSize() {
        width = parent.width*714/750
        height = parent.height*770/1333
        view.tableHeaderHeight = controller.parent.width*0.9*76/663;
    }

    Component.onCompleted: {
        updateWindowsSize();
        if(showSrvScore){
            Server.getWholeRecords(getDBKey(), saveServerRecords)            
        }
    }
/*time format = mSec*/
    function setScore(newScore, newDuration) {
        own.score = newScore
        if(typeof(newDuration)!="undefined") {
            own.timeDuration = newDuration
        }
        prepareNewRecordView()
    }

    function saveServerRecords(serverRecords, isServerAlive){
//        console.log("get server record", serverRecords)
        own.isServerAlive = isServerAlive
        if(isServerAlive){
            if(serverRecords.length == 0){  //only save deckName for the first time
                Server.saveDeckName(getDBKey(), UserSettings.gameDeck.split(".")[0].replace(/.*\//, ""))
            }
            own.serverRecords = serverRecords
            getSrvRecords()
        }
    }

    onGetSrvRecords: {
        if(view.viewType == Consts.idGlobal && !isPracticeMode){
            retryTimer.stop()
            NWPleaseWait.visible = false
            updateScoreToServer()  /*this function is called because previous high record might not be pushed to server
            due to lack of nekwork. Calling this function will not actually send data to server if the data is in server
            No bandwidth waste.*/
            if(view.viewType == Consts.idGlobal){
                fillHighScoreModel(getHighScores(Consts.idGlobal))
            }
        }
    }

    function updateScoreToServer(){
        var highScores = DbHandler.getHighScores(controller.getDBKey())
        for(var i = 0; i < highScores.length; i++){
                highScores[i].title = UserSettings.title
                own.serverRecords =
                        Server.updateRecords(getDBKey(), own.serverRecords, highScores[i])
        }

    }

    Component.onDestruction: {
        NWPleaseWait.visible = false
    }
}

