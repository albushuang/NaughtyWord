import QtQuick 2.0
import com.glovisdom.UserSettings 0.1
import "ModelSettingsInInsanity.js" as ModelInfo
import "settingValues.js" as Value
import "../generalModel"
import "qrc:/../../UIControls"
import "qrc:/NWUIControls"
import "qrc:/NWDialog"
import QtQuick.LocalStorage 2.0 as Sql


Item {id :root
    property int coins
    property int gems
    property variant storeItems: [Value.teacher, Value.smart, Value.invisible,
        Value.gravity, Value.shrinker, Value.redBull]
    property variant powerUpDscp: [] //Dscp = description
    property variant levelUpCostInCoins: {
        var temp = {}
        temp[Value.teacher] =   [ 3000,  7000, 15000, 35000, 70000]
        temp[Value.smart] =     [ 3000,  7000, 15000, 35000, 70000]
        temp[Value.invisible] = [ 6000, 15000, 30000, 50000, 100000]
        temp[Value.gravity] =   [ 8500, 20000, 40000, 80000, 150000]
        temp[Value.shrinker] =  [ 6000, 15000, 30000, 50000, 100000]
        temp[Value.redBull] =   [ 7000, 15000, 35000, 70000, 130000]
        return temp
    }

    property variant levelUpCostInGems: {
        var temp = {}
        temp[Value.teacher] =   [ 30,  70, 150, 350, 700]
        temp[Value.smart] =     [ 30,  70, 150, 350, 700]
        temp[Value.invisible] = [ 60, 150, 300, 500, 1000]
        temp[Value.gravity] =   [ 85, 200, 400, 800, 1500]
        temp[Value.shrinker] =  [ 60, 150, 300, 500, 1000]
        temp[Value.redBull] =   [ 70, 150, 350, 700, 1300]
        return temp
    }

    property variant textColor: {
        var temp = {}
        temp[Value.teacher] = "#ff9965"
        temp[Value.smart] = "#cd6667"
        temp[Value.invisible] = "#7e6698"
        temp[Value.gravity] = "#999967"
        temp[Value.shrinker] = "#669acc"
        temp[Value.redBull] = "#cc6698"
        return temp
    }

    property variant powerUpTitle: {
        var temp = {}
        //: 小老師
        temp[Value.teacher] = qsTr("Teacher")
        //: 聰明豆
        temp[Value.smart] = qsTr("Smart")
        //: 隱身術
        temp[Value.invisible] = qsTr("Invisible")
        //: 黑洞
        temp[Value.gravity] = qsTr("Black Hole")
        //: 縮小槍
        temp[Value.shrinker] = qsTr("Shrink Gun")
        //: 模範生
        temp[Value.redBull] = qsTr("Good Student")
        return temp
    }

    property variant insanitySettings
    property variant settings: [insanitySettings.teacher, insanitySettings.teacher,
        insanitySettings.invisible, insanitySettings.gravity,
        insanitySettings.shrinker, insanitySettings.redBull]

//    InsanitySettings{id: insanitySettings}

    DragMouseAndHint {
        target: root
        maxX: root.width
        toLeftToDo: stackView.makePreviousInvisible
        toRightToDo: stackView.pop
        dragToDo: stackView.makePreviousVisible
        remindCancelOption: true
        reminderDuration: 3000
        direction: "left"
        autoRun: true
        Component.onCompleted: {setExtensionMouse(dragMouseExtension)}
    }

    AutoImage{
        autoCalculateSize: false; anchors.fill: parent
        source: "qrc:/pic/insanity_store_BG.png"
    }

    AutoImage{ id: coinImg
        source: "qrc:/pic/insanity_store_star number.png"
        x: 281*hRatio; y:143 *vRatio
    }
    AutoImage{ id: coinTextBg
        source: "qrc:/pic/insanity_store_show number area.png"
        anchors{left: coinImg.right; rightMargin: 42*hRatio;verticalCenter: coinImg.verticalCenter}
    }
    Text{ id: coinText; color:"white"
        anchors.fill: coinTextBg
        text: coins
        font.pixelSize: hFontSize; fontSizeMode: Text.Fit; font.bold: true
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    AutoImage{ id: gemImg
        source: "qrc:/pic/insanity_store_diamond number.png"
        anchors{top: coinImg.bottom; topMargin: 12*vRatio; horizontalCenter: coinImg.horizontalCenter}
    }
    AutoImage{ id: gemTextBg
        source: "qrc:/pic/insanity_store_show number area.png"
        anchors{left: gemImg.right; rightMargin: coinTextBg.anchors.rightMargin;
            verticalCenter: gemImg.verticalCenter}
    }
    Text{ id: gemText; color:"white"
        anchors.fill: gemTextBg
        text: gems
        font.pixelSize: hFontSize; fontSizeMode: Text.Fit; font.bold: true
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    ListView{
        width: parent.width - x*2; height: parent.height - y
        x: 18*hRatio; y: 333*vRatio
        model: storeModel; delegate: storeDelegate
        spacing: 12*vRatio
        clip: true
    }

    MouseArea{id: dragMouseExtension
        width: 136*hRatio; height: parent.height
    }

    Component{
        id: storeDelegate
        Item{
            width: parent.width; height: 154*vRatio
            property int tFontSize: pixelDensity*3 // t stands for tiny
            AutoImage{  id: powerUpImg
                source: "qrc:/pic/insanity_store_" + powerUp +"_bar.png"
                x: 0; y:0
            }

            Text{id: powerUpTitleText; color: textColor[powerUp]
                width: 231*hRatio; height: 34*vRatio
                x:142*hRatio; y:14*vRatio
                text: powerUpTitle[powerUp]
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: hFontSize; minimumPixelSize: 9; font.bold: true
                wrapMode: Text.WordWrap;fontSizeMode: Text.Fit
            }

            Text{id: powerUpDscpText; color: textColor[powerUp]
                width: 400*hRatio; height: 26*vRatio
                x:powerUpTitleText.x; y:45*vRatio
//                width: 400*hRatio; height: 47*vRatio
//                x:160*hRatio; y:13*vRatio
                text: powerUpDscp[powerUp]
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: hFontSize; minimumPixelSize: 9; wrapMode: Text.WordWrap;fontSizeMode: Text.Fit
            }

            Row{ id: levelBlocks
                spacing: 12*hRatio
                x: powerUpTitleText.x; y: 75*vRatio
                Repeater{
                    model:3
                    AutoImage{id: eachBlock; source: level >= index ?
                                "qrc:/pic/insanity_store_" + powerUp +"_level frame01.png" :
                                "qrc:/pic/insanity_store_" + powerUp +"_level frame02.png"
                        width: 58*hRatio*0.9; height: 70*vRatio*0.9
                        Text{id:levelStatus; color: level >= index ? "white": textColor[powerUp]
                            text: (findPowerUpTable(powerUp).timer[index] != 0 ?
                                       findPowerUpTable(powerUp).timer[index]/1000 : "∞")
                                      + "\nsec." //Dont translate sec.
                            width: parent.width*0.95; height: parent.height*0.95
                            x: parent.width/2 - width/2; y: 3.5*vRatio
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
                            font.pixelSize: fFontSize; minimumPixelSize: 6; fontSizeMode: Text.Fit
                            lineHeight: 0.67
                        }
                    }

                }
            }

            AutoImage{ id: coinImg; visible: level < 5
                source: "qrc:/pic/insanity_store_star number.png"
                width: 54*hRatio; height: 54*vRatio
                x:530*hRatio; y: 18*vRatio
                MouseArea{anchors.fill: parent; enabled: level < 5
                    onClicked: {coinImg.coinsClicked() }
                }
                function coinsClicked(){
                    if(coins >= levelUpCostInCoins[powerUp][level]){
                        confirmation.hasTwoBtns = true
                        confirmation.callback = upgradeByCoins
                        confirmation.show(qsTr("Confirm upgrade?"))
                    }else{
                        confirmation.hasTwoBtns = false
                        confirmation.callback = function(){return;}
                        confirmation.show(qsTr("Coins are not enough"))
                    }
                }
                function upgradeByCoins(){
                    spendCoins()
                    upgradeLevel()
                }
                function spendCoins(){
                    coins -= levelUpCostInCoins[powerUp][level];
                }
                function upgradeLevel(){
                    storeModel.set(index, {powerUp: powerUp, level: level+1});
                    updateAllSettings();
                    fillPowerUpDscp(powerUp, level)
                }

            }

            Text{id: levelUpByCoins; color: textColor[powerUp]
                text: level < 5 ? levelUpCostInCoins[powerUp][level] : ""
                width:108*hRatio; height: 33*vRatio
                anchors{left: coinImg.right; leftMargin: 7*hRatio; verticalCenter: coinImg.verticalCenter}
                font.pixelSize: iFontSize; fontSizeMode: Text.Fit; font.bold: true
                MouseArea{anchors.fill: parent; enabled: level < 5
                    onClicked:{ coinImg.coinsClicked()}
                }
            }

            AutoImage{ id: gemImg; visible: level < 5
                source: "qrc:/pic/insanity_store_diamond number.png"
                width: 54*hRatio; height: 54*vRatio
                x: coinImg.x; y: 82*vRatio
                MouseArea{anchors.fill: parent; enabled: level < 5
                    onClicked: {gemImg.gemClicked() }
                }
                function gemClicked(){
                    if(gems >= levelUpCostInGems[powerUp][level]){
                        confirmation.hasTwoBtns = true
                        confirmation.callback = upgradeByGems
                        confirmation.show(qsTr("Confirm upgrade?"))
                    }else{
                        confirmation.hasTwoBtns = false
                        confirmation.callback = function(){return;}
                        confirmation.show(qsTr("Gems are not enough"))
                    }
                }
                function upgradeByGems(){
                    spendCoins()
                    upgradeLevel()
                }
                function upgradeLevel(){
                    storeModel.set(index, {powerUp: powerUp, level: level+1});
                    updateAllSettings();
                    fillPowerUpDscp(powerUp, level)
                }

                function spendCoins(){
                    gems -= levelUpCostInGems[powerUp][level];
                }
            }

            Text{id: levelUpByGems; color: textColor[powerUp]
                text: level < 5 ? levelUpCostInGems[powerUp][level] : ""
                width:levelUpByCoins.width; height: levelUpByCoins.height
                anchors{left: gemImg.right; leftMargin: levelUpByCoins.anchors.leftMargin;
                    verticalCenter: gemImg.verticalCenter}
                font.pixelSize: levelUpByCoins.font.pixelSize; fontSizeMode: Text.Fit; font.bold: true
                MouseArea{anchors.fill: parent; enabled: level < 5
                    onClicked:{ gemImg.gemClicked()}
                }
            }


        }
    }
    NWDialogControl{id: confirmation
        hasInput: false
        width: parent.width*0.618
    }

    ListModel{ id: storeModel}

    Component.onCompleted: {
        coins = UserSettings.coins
        gems = UserSettings.gems

        fillModelAndPowerUpDscp();
    }


    function fillModelAndPowerUpDscp(){
        for(var i = 0; i < storeItems.length; i++){
            var level = insanitySettings[storeItems[i]]
//            console.log(i,level)
            storeModel.append({powerUp: storeItems[i], level: parseInt(level)});
            fillPowerUpDscp(storeItems[i], parseInt(level))
        }
    }

    function fillPowerUpDscp(powerUp, level){
        var powerUpTable = findPowerUpTable(powerUp);
        switch(powerUp){
        case Value.teacher: //: "有高手提示你答案"
            powerUpDscp[powerUp] = qsTr("A teacher gives you a hint") ;
            break;
        case Value.smart: //:"變聰明: 不會吃到錯的"
            powerUpDscp[powerUp] = qsTr("Become smart. Will not touch wrong answers") ;
            break;
        case Value.invisible: //:"碰不到星球"
            powerUpDscp[powerUp] = qsTr("Will not be hit by stars");
            break;
        case Value.gravity: //:"星球速度變慢為 x% (升級: x%)"
            //:%1 is a variable set by developers. It doesn't mean one percent.
            powerUpDscp[powerUp] = qsTr("Stars become slower to %1%").arg(100*(powerUpTable.effects[level])) +
                    (level < 5 ? qsTr("(Lv up: %1%)").arg(100*(powerUpTable.effects[level+1])) : "")
            break;
        case Value.shrinker:    //: "星球縮小成 x% (升級:x%)"
            //:%1 is a variable set by developers. It doesn't mean one percent.
            powerUpDscp[powerUp] = qsTr("Stars shrink to %1%").arg(100*(powerUpTable.effects[level])) +
                    (level < 5 ? qsTr("(Lv up: %1%)").arg(100*(powerUpTable.effects[level+1])) : "")
            break;
        case Value.redBull: //:"答對分數加乘 x倍" (升級: x倍)"
            //:%1 is a variable set by developers. It doesn't mean one percent.
            powerUpDscp[powerUp] = qsTr("%1x bonus score").arg(powerUpTable.effects[level]) +
                    (level < 5 ? qsTr("(Lv up: %1%)").arg(powerUpTable.effects[level+1]) : "")
            break;
        }
        powerUpDscp = powerUpDscp   //To trigger property binding by assigning variant as whole
    }

//    function fillPowerUpDscp(powerUp, level){
//        var powerUpTable = findPowerUpTable(powerUp);
//        switch(powerUp){
//        case Value.teacher:
//            powerUpDscp[powerUp] = "有高手提示你答案" + powerUpTable.timer[level]/1000 + "秒" +
//                    (level < 5 ? "(升級:" + powerUpTable.timer[level+1]/1000 + "秒)" : "");
//            break;
//        case Value.smart:
//            powerUpDscp[powerUp] = "變聰明: 不會吃到錯的" + powerUpTable.timer[level]/1000 + "秒" +
//                    (level < 5 ? "(升級:" + powerUpTable.timer[level+1]/1000 + "秒)" : "");
//            break;
//        case Value.invisible:
//            powerUpDscp[powerUp] = "隱身，碰不到星球" + powerUpTable.timer[level]/1000 + "秒" +
//                    (level < 5 ? "(升級:" + powerUpTable.timer[level+1]/1000 + "秒)" : "");
//            break;
//        case Value.gravity:
//            powerUpDscp[powerUp] = "強大的引力讓星球速度變慢為" + 100*powerUpTable.effects[level] + "%，永久有效!!" +
//                    (level < 5 ? "(升級:" + 100*powerUpTable.effects[level+1] + "%)" : "");
//            break;
//        case Value.shrinker:
//            powerUpDscp[powerUp] = "縮小槍！！將星球縮小成" + 100*powerUpTable.effects[level] + "%,持續" + powerUpTable.timer[level]/1000 + "秒" +
//                    (level < 5 ? "(升級:" + 100*powerUpTable.effects[level+1] + "%, " + powerUpTable.timer[level+1]/1000 + "秒)" : "")
//            break;
//        case Value.redBull:
//            powerUpDscp[powerUp] = "答對分數加乘" + powerUpTable.effects[level] + "倍,持續" + powerUpTable.timer[level]/1000 + "秒" +
//                    (level < 5 ? "(升級:" + powerUpTable.effects[level+1] + "倍, " + powerUpTable.timer[level+1]/1000 + "秒)" : "")
//            break;
//        }
//        powerUpDscp = powerUpDscp   //To trigger property binding by assigning variant as whole
//    }

    function findPowerUpTable(powerUp){
        for(var i = 0; i < ModelInfo.powerUpTables.length; i++){
            if(ModelInfo.powerUpTables[i].type == powerUp)
                return ModelInfo.powerUpTables[i];
        }
        console.assert(false, "Impossible that we cannot find " + powerUp + " in powerUpTables")
    }

    function updateAllSettings(){
        UserSettings.coins = coins
        UserSettings.gems = gems

        for(var i = 0; i < storeItems.length; i++){
            insanitySettings[storeItems[i]] = storeModel.get(i).level
        }
    }


}

