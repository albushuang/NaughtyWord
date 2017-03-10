import QtQuick 2.5
import QtQuick.Window 2.2

// protocol:
//   clickedOnFile(), clickToCancelSelected()
Item { id: controller

    DirectoryModel { id: dirViewModel }

    function clickedOnFile(index, fileName) {
        own.pushOrPop(own.fileList, fileName);
        own.pushOrPop(own.indexList, index);
    }

    function clickToCancelSelected() {
        own.fileList = [];
        own.indexList = [];
        gc();
    }

    function copyShort(targetName) {
        if (own.fileList.count != 1) return false;
        dirViewModel.copyShortNameFile(own.fileList[0], targetName);
        clickToCancelSelected();
        return true;
    }

    function renameShort(targetName) {
        if (own.fileList.count != 1) return false;
        dirViewModel.renameShortNameFile(own.fileList[0], targetName);
        clickToCancelSelected();
        return true;
    }

    function removeShort(nameList) {
        dirViewModel.renameShortNameFiles(own.fileList);
        clickToCancelSelected();
    }

    QtObject { id: own
        property var fileList: [];
        property var indexList: [];
        function pushOrPop(array, candidate) {
            var found = false;
            for(var i=0; i<array.count;i++) {
                if (array[i]==candidate) {
                    array.splice(i, 1);
                    found = true;
                    break;
                }
            }
            if(!found) { list.push(candidate); }
        }
    }

}

