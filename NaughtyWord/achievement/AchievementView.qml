import QtQuick 2.0
import com.glovisdom.UserSettings 0.1
import "../generalModel"
import "qrc:/../../UIControls"
import "qrc:/NWUIControls"
import "qrc:/NWDialog"
import "../GameInsanity/settingValues.js" as Value
import "../GameInsanity/ModelSettingsInInsanity.js" as ModelInfo
import QtQuick.LocalStorage 2.0 as Sql

//TODO: remove all "store"
Item {id :root
    anchors.fill: parent
    property int coins
    property variant storeItems: [Value.teacher, Value.smart, Value.invisible,
        Value.gravity, Value.shrinker, Value.redBull]
    property variant powerUpDscp: [] //Dscp = description

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
        source: "qrc:/pic/gameSelect_diamond.png"
        x: 281*hRatio; y:143 *vRatio
        width: 88*hRatio; height: 88*vRatio
    }
    AutoImage{ id: coinTextBg
        source: "qrc:/pic/insanity_store_show number area.png"
        anchors{left: coinImg.right; rightMargin: 42*hRatio;verticalCenter: coinImg.verticalCenter}
    }

    Text{ id: coinText; color:"white"
        anchors.fill: coinTextBg
        text: "340"
        font.pixelSize: hFontSize; fontSizeMode: Text.Fit; font.bold: true
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
    }

    ListView{
        width: parent.width - x*2; height: parent.height - y
        x: 18*hRatio; y: 250*vRatio
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

//            Row{ id: levelBlocks
//                spacing: 12*hRatio
//                x: powerUpTitleText.x; y: 75*vRatio
//                Repeater{
//                    model:6
//                    AutoImage{id: eachBlock; source: level >= index ?
//                                "qrc:/pic/insanity_store_" + powerUp +"_level frame01.png" :
//                                "qrc:/pic/insanity_store_" + powerUp +"_level frame02.png"
//                        width: 58*hRatio*0.9; height: 70*vRatio*0.9
//                        Text{id:levelStatus; color: level >= index ? "white": textColor[powerUp]
//                            text: (findPowerUpTable(powerUp).timer[index] != 0 ?
//                                       findPowerUpTable(powerUp).timer[index]/1000 : "∞")
//                                      + "\nsec." //Dont translate sec.
//                            width: parent.width*0.95; height: parent.height*0.95
//                            x: parent.width/2 - width/2; y: 3.5*vRatio
//                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
//                            font.pixelSize: fFontSize; minimumPixelSize: 6; fontSizeMode: Text.Fit
//                            lineHeight: 0.67
//                        }
//                    }

//                }
//            }

            AutoImage{ id: coinImg; visible: level < 5
                source: "qrc:/pic/gameSelect_diamond.png"
                width: 54*hRatio; height: 54*vRatio
                x:580*hRatio; anchors{verticalCenter: parent.verticalCenter}

            }

            Text{id: levelUpByCoins; color: textColor[powerUp]
                text: "10"
                width:108*hRatio; height: 33*vRatio
                anchors{left: coinImg.right; leftMargin: 7*hRatio; verticalCenter: coinImg.verticalCenter}
                font.pixelSize: iFontSize; fontSizeMode: Text.Fit; font.bold: true
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

        fillModelAndPowerUpDscp();
    }


    function fillModelAndPowerUpDscp(){

        for(var i = 0; i < storeItems.length; i++){
            var level = 0
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


    function findPowerUpTable(powerUp){
        for(var i = 0; i < ModelInfo.powerUpTables.length; i++){
            if(ModelInfo.powerUpTables[i].type == powerUp)
                return ModelInfo.powerUpTables[i];
        }
        console.assert(false, "Impossible that we cannot find " + powerUp + " in powerUpTables")
    }

    function updateAllSettings(){
        UserSettings.coins = coins

        for(var i = 0; i < storeItems.length; i++){
            insanitySettings[storeItems[i]] = storeModel.get(i).level
        }
    }


}

