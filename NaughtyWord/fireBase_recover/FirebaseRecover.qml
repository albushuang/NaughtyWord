import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import AppSettings 0.1
import com.glovisdom.AnkiDeck 0.1
import com.glovisdom.UserSettings 0.1
import com.glovisdom.NWPleaseWait 0.1
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/chooseDeck.js" as Choose
import "../DictLookup/vocabularyServer.js" as Server
import "../generalModel"
import "../DirectoryView"


/*This qml can get imageURL from each deck in /Application Support/Naughty Word/decks/. Push those
imageURL back to firebase server. (Because firebase might lose the data for unknown reason. */
Rectangle {id: root; color: "blue"; radius: 10; width: 200; height: 50
    property var wordsFromServer  //words data from server
    Text{text: "Start recover"; color: "white"
        anchors.fill: parent; font.pixelSize: 999; fontSizeMode: Text.Fit
        MouseArea{
            anchors.fill: parent
            onClicked:{
                waitFolderModelLoading.start()
                NWPleaseWait.visible = true
            }
        }
    }

    Component.onCompleted: {
        Server.getWords(saveWords)
    }
    function saveWords(data){
        wordsFromServer = data
        console.log("number of words:", Object.keys(data).length)
    }

    DirectoryModel{id: dirViewModel
        showDirs: true
    }
    AppSettings{id: appSettings
        Component.onCompleted: {
            dirViewModel.setPath(appSettings.readSetting(AppKeys.pathInSettings))
//            dirViewModel.folderModel.countChanged.connect(own.folderModelChangedHandler)                        
        }
    }

    Timer{id: waitFolderModelLoading; interval: 2000
        onTriggered: {
            console.log("number of decks:", dirViewModel.folderModel.count)
            startRecover()
        }
    }


    function startRecover(){
        var folderModel = dirViewModel.folderModel
        console.log("path", appSettings.readSetting(AppKeys.pathInSettings))

        var deckMedia = Choose.createMedia(root,
                   appSettings.readSetting(AppKeys.pathInSettings),
                   { deck: UserSettings.gameDeck, soundON: UserSettings.soundGameON })

        for(var i = 0; i < folderModel.count; i++){
            console.log("deck name:", folderModel.get(i, "fileName"))
            deckMedia.setDeck(folderModel.get(i, "fileName"))
            pushImageUrlToServer(deckMedia)
        }
        deckMedia.destroy()

    }

    function pushImageUrlToServer(deckMedia){
        var allCards = deckMedia.fetchCards(-1, AnkiDeck.All, AnkiDeck.Random, "", 0)
        console.log("card num:", allCards.length)
        for (var i = 0; i < allCards.length; i++){
            if(typeof(wordsFromServer[allCards[i].word]) != "undefined"){
                console.log("find word on server: ", allCards[i].word)
                Server.saveImageUrlToServer(allCards[i].word, allCards[i].imageURL, wordsFromServer[allCards[i].word])
            }else{
                console.log("NOT find word on server: ", allCards[i].word)
                Server.saveImageUrlToServer(allCards[i].word, allCards[i].imageURL, {})
            }
        }
        NWPleaseWait.visible = false
    }

}

