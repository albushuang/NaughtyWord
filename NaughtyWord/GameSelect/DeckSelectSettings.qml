import QtQuick 2.0
import Qt.labs.settings 1.0
import com.glovisdom.UserSettings 0.1
import "qrc:/generalModel"
import "../generalJS/deckCategoryConsts.js" as CateConst
/*If we want to add these settings into userSettings. We have to be careful not to create two
userSettings instance. For example, if we create a instance in GameSelectController, we cannot
create another instance in any following game (GameSelectController is still in StackView.)*/
/*Strongly recommand this item singleton*/

Settings {
    category: "DeckSelect"
/*if UserSettings.gameDeck = antipasti.lif.tvl.kmrj, lastSelection will be antipasti.lif
   or antipasti.tvl which depends on what category last user select*/
    property string lastSelection: UserSettings.defaultDeck.split(".")[0] + "." +
                                    UserSettings.defaultDeck.split(".")[1]

    /*Remember if filer is on or off*/
    property bool test : true
    property bool school : true
    property bool profession : true
    property bool life : true
    property bool entertainment: true
    property bool travel : true
    Component.onCompleted: {
        console.log("Settings:", lastSelection, UserSettings.defaultDeck)
    }
}

