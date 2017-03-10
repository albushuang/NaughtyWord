import QtQuick 2.0
import "qrc:/GameSelect"
import AppSettings 0.1
import "qrc:/generalModel"
import "qrc:/../../UIControls"
import "qrc:/DictLookup"
import "qrc:/deckManagement"
import "qrc:/NWDialog"
import "../generalJS/appsettingKeys.js" as AppKeys
import "../generalJS/objectCreate.js" as Create
import com.glovisdom.UserSettings 0.1
import CardMover 0.1

Item { id: controller
    property var callBack
    property CardMover mover
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
            deckSelcSettings.lastSelection = fileName
            own.setTargetDeck(index)
        }
    }

    DeckSelectModel{id: thisModel
        Component.onCompleted: {
            dirViewModel.setPath(appSettings.readSetting(AppKeys.pathInSettings))
            dirViewModel.folderModel.countChanged.connect(own.folderModelChangedHandler)
        }
    }

    property alias categoryModel: thisModel.categoryModel
    property alias dirViewModel: thisModel.dirViewModel
    property alias displayModel: thisModel.displayModel

    QtObject { id: own
        function extraAction(pp, fn, ind) {
            var files = mover.getRowCounts(displayModel.get(ind).fullFileName)
            var txt = "import QtQuick 2.0; Text { color: \"yellow\"; font.pointSize: 18; text: \"" + files + "\" }"
            var obj = Qt.createQmlObject(txt, pp);
        }

        function setTargetDeck(ind) {
            var fn = displayModel.get(ind).fullFileName
            callBack(fn)
            visible = false
        }

        function init(){
            categoryModel.fillModel()
            setFilters()
        }
        function getImgBackground(ext){
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).ext == ext){
                    return categoryModel.get(i).deckBg
                }
            }
        }
        function setFilters(){
            var filter = []
            for(var i = 0; i < categoryModel.count; i++){
                if(categoryModel.get(i).isFilterOn){ filter.push("*" + categoryModel.get(i).ext + ".*")}
            }
            dirViewModel.setFilter(filter)
            folderModelChangedHandler()
        }
        function setLastSelection(){
            for(var i = 0; i < displayModel.count; i++){
                if(displayModel.get(i).fileName == deckSelcSettings.lastSelection){
                    mainView.currentIndex = i
                    return
                }
            }
            mainView.currentIndex = 0   //Set 0 if cannot find it
        }
        function folderModelChangedHandler(){
            displayModel.setModel()
            setLastSelection()
        }
    }
}

