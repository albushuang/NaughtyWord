import QtQuick 2.0
import "../DirectoryView"
import "../generalModel"
import "decksViewConst.js" as Const
import "../generalJS/deckCategoryConsts.js" as CateConst


Item {id: root
    property alias popupModel: popupModel
    property variant enumPopupDirection

    signal requestDialog(string text, bool hasTwoBtn, bool hasInput, variant callback)
    signal requestPopup(variant popupModel, variant callback, int direction)
    signal requestGgPubLinkDl(string url)
    signal requestCouldDl()


    ListModel { id: popupModel
        Component.onCompleted: {
            append({ id: Const.idDlByUrl, display: Const.disDlByUrl });
            append({ id: Const.idDlByCloud, display: Const.disDlByCloud});
        }
    }

    function cloudClicked(){
        requestPopup(popupModel, own.handlePopupClicked, enumPopupDirection.down)
    }

    QtObject{id: own
        function downloadByUrl(url){
            requestGgPubLinkDl(url)
        }

        function handlePopupClicked(id, index){
            switch(id){
            case Const.idDlByUrl:
                var msg = qsTr("Please paste Google drive public sharing link")
                requestDialog(msg, true, true, own.downloadByUrl)
                break;
            case Const.idDlByCloud:
                requestCouldDl()
                break;
            }
        }
    }
}

