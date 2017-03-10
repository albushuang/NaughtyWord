import QtQuick 2.0
import com.glovisdom.UserSettings 0.1
import "../NWUIControls"
import "../generalJS/tutorialScript.js" as TutScript

Item { id: tutor
    property NWTutorial tutorial;
    property bool hasTutorial: false

    Component.onDestruction: {
        if(tutorial!=null) { tutorial.destroy() }
    }

    function startHanldeTutorial(result, objId, qmlName){
        if(result && qmlName == tutorialQmlUrl){
            tutorial = objId
            hasTutorial = true
            tutorial.foggyAreaClicked.connect(foggyAreaClicked)
            tutorial.runningTextClickAgain.connect(foggyAreaClicked)

            if(!UserSettings.tutUseAnotherKeyWord1){
                imageBrowserController.needMoreImage.connect(useOtherKeyWordTutorial1)
                imageBrowserController.iBrowser.imageBrowserClicked.connect(useOtherKeyWordTutorial2)
            }
            if(!UserSettings.tutUseDictionary){
                view.stateChanged.connect(useDictionaryTutorial)
            }
        }
    }

    function useDictionaryTutorial(){
        if(view.state == "result" && !UserSettings.tutUseDictionary){
            tutorial.tutorialKey = TutScript.tutUseDictionary
            tutorial.focusFrameEnabled = false
            tutorial.focusItem = view.imageBrowser
            tutorial.start(600)
        }
    }

    function saveWordTutorial(){
        if(!UserSettings.tutSaveWord){
            tutorial.tutorialKey = TutScript.tutSaveWord
            tutorial.focusItem = view.addCardBtn
            tutorial.start()
        }
    }

    function useOtherKeyWordTutorial1(){
        if(!UserSettings.tutUseAnotherKeyWord1){
            tutorial.tutorialKey = TutScript.tutUseAnotherKeyWord1
            tutorial.focusItem = view.imageBrowser
            tutorial.start()
        }
    }

    function useOtherKeyWordTutorial2(){
        if(hasTutorial && tutorial.isOnGoing(TutScript.tutUseAnotherKeyWord1)){
            tutorial.stop()
            tutorial.tutorialKey = TutScript.tutUseAnotherKeyWord2
            tutorial.focusItem = view.searchOtherImage
            hideKeyboard.start()    //weird bug, use timer to work around
            tutorial.start(600)
        }
    }
    Timer{ id: hideKeyboard; interval: 30;
        onTriggered: tutor.parent.allInputMethodFocusFalse();
    }


    function stopTutorial(key){
        tutorial.stop()
        UserSettings[key] = true
    }

    function foggyAreaClicked(){
        if(hasTutorial && tutorial.isOnGoing(TutScript.tutUseDictionary)){
            stopTutorial("tutUseDictionary")
            if(!UserSettings.tutSaveWord){
                saveWordTutorial()
            }
        }else if(hasTutorial && tutorial.isOnGoing(TutScript.tutSaveWord)){
            stopTutorial("tutSaveWord")
        }else if(hasTutorial && tutorial.isOnGoing(TutScript.tutUseAnotherKeyWord2)){
            stopTutorial("tutUseAnotherKeyWord1")
        }
    }

    function isOnGoing(script) {
        if(tutor.hasTutorial) {
            var key
            switch(script) {
            case "tutSaveWord": key = TutScript.tutSaveWord; break;
            case "tutUseAnotherKeyWord1": key = TutScript.tutUseAnotherKeyWord2; break;
            }
            if (tutorial.isOnGoing(key)){ stopTutorial(script) }
        }
    }
}

