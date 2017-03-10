import QtQuick 2.0
import AppSettings 0.1
import com.glovisdom.UserSettings 0.1
import "../DirectoryView"
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/deckCategoryConsts.js" as CateConst
import "../generalJS/objectCreate.js" as CompCreator
import "../generalJS/tutorialScript.js" as TutScript
import "../generalModel"
import "../NWUIControls"

Item { id: root; anchors.fill: parent;
    property alias view: mainView
    signal deckChoosen(string deck, bool triggeredByUser)
    signal dlClicked()
    signal userChangeDeckWindow()

    AppSettings{id: appSettings}
    DeckSelectSettings{id: deckSelcSettings
        Component.onCompleted: {
            own.init()
        }
    }

    DeckSelectView{ id: mainView
        cateModel: categoryModel
        decksModel: displayModel
        delegator: own
        onCategoryClicked: {
            categoryModel.updateIsFilterOn(index, isOn)
            deckSelcSettings[settingKey] = isOn
            own.setFilters(index, isOn)
        }
        onDeckClicked: {
//            console.log("fileName",fileName)
            deckSelcSettings.lastSelection = fileName
            own.setGameDeck(true)   /*lastSelection has incomplete extension, set full fileName to gameDeck*/
        }
        onDlClicked: {root.dlClicked()}
        onDeckArrowClicked: {
            userChangeDeckWindow()
            handleTutorialClickMoreDecks()
        }
    }

    DeckSelectModel{id: thisModel
        Component.onCompleted: {
            dirViewModel.setPath(appSettings.readSetting(AppKeys.pathInSettings))
            dirViewModel.folderModel.countChanged.connect(own.folderModelChangedHandler)
//            console.log(appSettings.readSetting(AppKeys.pathInSettings))
        }
    }

    property alias categoryModel: thisModel.categoryModel
    property alias dirViewModel: thisModel.dirViewModel
    property alias displayModel: thisModel.displayModel


    QtObject{id: own
        function init(){
            categoryModel.fillModel()   //Dont mix the following code's order
            setFilters()
            /*After setting filters. folderModel will not be ready immediately.
            So use folderModel.countChanged signal to call folderModelChangedHandler() when folderModel is ready*/
        }

        function setFilters(){
            var filter = []
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).isFilterOn){ filter.push("*" + categoryModel.get(i).ext + ".*")}
            }
//            console.log("filter", filter)
            dirViewModel.setFilter(filter)
            /*Sometimes, changing category filter might not lead to folderModel's countChanged. But we still
            have to call displayModel.setModel() & setLastSelection() because some extensions are changed*/
            folderModelChangedHandler()
        }

        function folderModelChangedHandler(){
            displayModel.setModel()
            setLastSelection()
            setGameDeck(false)
        }

        function setLastSelection(){
//            console.log("displayModel.count", displayModel.count)
//            console.log("deckSelcSettings.lastSelection", deckSelcSettings.lastSelection)
            for(var i = 0; i < displayModel.count; i++){
//                console.log("displayModel.get(i).fileName", displayModel.get(i).fileName)
                if(displayModel.get(i).fileName == deckSelcSettings.lastSelection){
//                    console.log("currentIndex",i)
                    mainView.currentIndex = i
                    return
                }
            }
            mainView.currentIndex = 0   //Set 0 if cannot find it
        }

        function setGameDeck(userClicked){
//            console.log("fullFileName", displayModel.get(mainView.currentIndex).fullFileName)
            if(typeof(displayModel.get(mainView.currentIndex)) != "undefined"){
//                console.log("fullFileName", displayModel.get(mainView.currentIndex).fullFileName)
                UserSettings.gameDeck = displayModel.get(mainView.currentIndex).fullFileName
                deckChoosen(UserSettings.gameDeck, userClicked)
            }
        }

        function getImgBackground(ext){
//            console.log("ext",ext)
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).ext == ext){
                    return categoryModel.get(i).deckBg
                }
            }
        }
    }


    property string tutorialQmlUrl: "../NWUIControls/NWTutorial.qml"
    property NWTutorial tutorial;
    property variant tutArrayInThisQML: [UserSettings.tutClickMoreDecks, UserSettings.tutSelectOtherDeck ]
    property bool hasTutorial: false

    function handleTutorialCompComplete(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked);
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)
        }
    }

    function handleTutorialClickMoreDecks(){
        if(!UserSettings.tutClickMoreDecks){
            tutorial.tutorialKey = TutScript.tutClickMoreDecks
            tutorial.focusItem = mainView.dlBtn
            tutorial.start(600)
            mainView.onDlClicked.connect(stopClickMoreDecksTutorial)
        }
    }

    function handleTutorialSelectOtherDeck(){
        if(!UserSettings.tutSelectOtherDeck){
            mainView.onDeckClicked.connect(stopSelectOtherDeckTutorial)
            tutorial.tutorialKey = TutScript.tutSelectOtherDeck
            tutorial.focusItem = mainView.decksView
            tutorial.start(600)
        }
    }

    function stopClickMoreDecksTutorial(){
        try {
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutClickMoreDecks)){                
                tutorial.stop()
                UserSettings.tutClickMoreDecks = true
                mainView.onDlClicked.disconnect(stopClickMoreDecksTutorial)
            }
        } catch (err) {
            console.error("stop tutorial error:", err)
            UserSettings.tutClickMoreDecks = true
            if(tutorial != null) { tutorial.destroy() }
        }

    }

    function stopSelectOtherDeckTutorial(){
        try {
            if(hasTutorial && tutorial.isOnGoing(TutScript.tutSelectOtherDeck)){                
                tutorial.stop()
                UserSettings.tutSelectOtherDeck = true
                mainView.onDeckClicked.disconnect(stopSelectOtherDeckTutorial)
            }
        } catch (err) {
            console.error("stop tutorial error:", err)
            UserSettings.tutSelectOtherDeck = true
            if(tutorial != null) { tutorial.destroy() }
        }
    }


    function foggyAreaClicked(){    //Do nothing in this case
    }

    Component.onCompleted: {
        for(var i = 0; i < tutArrayInThisQML.length; i++){
            if(!tutArrayInThisQML[i]){
                CompCreator.createComponent(gameSelectControl, tutorialQmlUrl,
                                        {width: gameSelectControl.width, height: gameSelectControl.height},
                                            handleTutorialCompComplete)
                break;
            }
        }
    }


}

