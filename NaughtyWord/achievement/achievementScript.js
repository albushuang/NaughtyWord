.pragma library
function getScriptObj(key){
    for(var i = 0; i < wholeTable.length; i++){
        if(wholeTable[i].key == key){
            return wholeTable[i]
        }
    }
    console.assert(false, "WholeTable should contain the key:" + key)
}


//All achievement keys
var achvDmReflection = 0    //Dm stands for direct match
var achvDmPractice = 1
var achvDmContinuous = 2

//這些圖片全部沒有版權，只是demo用
var wholeTable =
        [{
             key : achvDmReflection,
             imageSource: "qrc:/pic/tutorial.png",
             title: qsTr("你的反應無極限"),
             goal: qsTr("一秒以內答對超過50次")
         },{
             key : achvDmPractice,
             imageSource: "qrc:/pic/tutorial.png",
             title: qsTr("練習，是為了走更長遠的路"),
             goal: qsTr("複習過的單字超過200個")
         },{
             key : achvDmContinuous,
             imageSource: "qrc:/pic/tutorial.png",
             title: qsTr("你該不會整組卡牌都背起來了吧？"),
             goal: qsTr("連續打對超過10次")
         }


        ]
