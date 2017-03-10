import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import com.glovisdom.UserSettings 0.1
import QmlAdMob 0.1
import "qrc:/NWDialog"

NWDialog { id: grandpa
    property QmlAdMob adMob
    property var deleteLater
    state: "onlyTwoButtons"
    delegator: own
    hasInput: false
    anchors.centerIn: parent
    message: qsTr("Support us by watching adv then obtain 200 gold?")
    QtObject { id: own
        property bool toShow: false
        function yesClicked(text) {
            own.toShow = true
            grandpa.message = qsTr("Loading...")
            var unitID
            if(Qt.platform.os=="android") { unitID = "ca-app-pub-1482222222222222/8888555555" }
            else { unitID = "ca-app-pub-1482222222222222/1666666688" }
            adMob.rewardedVideoAdLoad(unitID)
        }

        function noClicked(text) {
            deleteLater(grandpa)
        }
        function onLoaded() {
            if(toShow) { adMob.rewardedVideoAdShow() }
        }
        function onRewarded(type, amount) {
            console.log("you got: ", type, ", with amount:" ,amount)
            UserSettings.allGold += 200
        }
        function onRewardedVideoAdEnded() {
            deleteLater(grandpa)
        }
    }
    Component.onCompleted: {
        adMob.rewardedVideoAdLoaded.connect(own.onLoaded)
        adMob.rewarded.connect(own.onRewarded)
        adMob.rewardedVideoAdEnded.connect(own.onRewardedVideoAdEnded)
    }
    Component.onDestruction: {
        adMob.rewardedVideoAdLoaded.disconnect(own.onLoaded)
        adMob.rewarded.disconnect(own.onRewarded)
        adMob.rewardedVideoAdEnded.disconnect(own.onRewardedVideoAdEnded)
    }
}
