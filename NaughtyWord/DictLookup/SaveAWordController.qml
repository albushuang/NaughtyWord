import QtQuick 2.0
import QtQuick.Controls 1.3
import "qrc:/../../UIControls"
import "vocabularyServer.js" as Server
import com.glovisdom.UserSettings 0.1

Item { id: saveCard
    property string imageURL
    property string imageTBURL
    property string finalImageURL
    property string speechURL
    property string userDeck: ""
    property var deckMedia
    property var makeWordCallback
    property bool acquireImage: true
    property bool acquireSpeech: true
    property alias message: busy.message
    property alias show: busy.visible
    property alias imageGetter: wordSaver.imageGetter
    property int dbImageWidth: 512
    property int dbImageHeight: 512
    property var cropInfo
    property variant dataFromServer
    signal saveCompeleted(var object);

    PleaseWait { id: busy
        state: "running"
        anchors.fill: parent
        visible: true
        color: "#E0F5FF"
        externalFontSize: UserSettings.fontPointSize+2
        Image { id: btnOK
            source: "qrc:/pic/buttonOK.png"
            visible: false
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 20 }
            MouseArea { anchors.fill: parent
                onClicked: { saveCardEnd() }
            }
        }
        message: qsTr("Saving, please wait.")
    }

    SaveAWordModel { id: wordSaver
        onImageTaskOK: {
            acquireImage = false;
            finalImageURL = url;
            if(!UserSettings.autoDict && url!=imageTBURL) {
                Server.saveImageUrlToServer(makeWordCallback("", "").word, finalImageURL, dataFromServer)
            }
            addCard2Deck();            
        }
        onImageTaskNetIssue:  {
            acquireImage = false;
            addCard2Deck();
        }
        onImageTaskFailed: {
            if(url==imageURL) {
                wordSaver.setImage(imageTBURL);
            } else {
                finalImageURL = "";
                acquireImage = false;
                addCard2Deck();
            }
        }

        onSpeechTaskOK: {
            acquireSpeech = false;
            speechURL = url
            addCard2Deck();
        }
        onSpeechTaskFailed: {
            acquireSpeech = false;
            speechURL = "";
            addCard2Deck();
        }
        onSpeechTaskNetIssue: {
            acquireSpeech = false;
            addCard2Deck();
        }
    }

    anchors.centerIn: parent

    function setImageURL(url, tbUrl) {
        imageURL = url;
        imageTBURL = tbUrl;
        wordSaver.setImage(imageURL);
    }

    function setSpeechURL(url) {
        speechURL = url;
        wordSaver.setSpeech(speechURL);
    }

    function setUserDeck (deck) {
        userDeck = deck;
    }
    
    function addCard2Deck() {
        if (acquireImage == false && acquireSpeech == false) {
            var wordJSON = makeWordCallback(finalImageURL, speechURL);
            //console.log("adding to...", userDeck, finalImageURL, speechURL)
            if (!wordSaver.addCard(deckMedia, wordJSON, userDeck, cropInfo, dbImageWidth, dbImageHeight))
            {
                if(finalImageURL==imageTBURL) {
                    busy.message = qsTr("Failed to add card.");
                    busy.state = "stopped";
                    btnOK.visible = true;
                    if(UserSettings.autoDict) {
                        saveCardEnd(wordJSON.word)
                    }
                } else { wordSaver.setImage(imageTBURL); }
            } else {
                if(finalImageURL==imageTBURL && finalImageURL!=imageURL) {
                    //: Wanring users they save only the thumbnail of the image, not the entire image.
                    busy.message = qsTr("Image download failed. Only thumbnail is saved.");
                    busy.state = "stopped";
                    btnOK.visible = true;
                    if(UserSettings.autoDict) {
                        saveCardEnd(wordJSON.word)
                    }
                } else { saveCardEnd(wordJSON.word) }
            }
        }
    }
    function saveCardEnd(word){
        saveCompeleted(saveCard);
    }
}
