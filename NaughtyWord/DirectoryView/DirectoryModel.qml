import QtQuick 2.5
import QtQuick.Window 2.2
import Qt.labs.folderlistmodel 2.1
import FileCommander 0.1
import com.glovisdom.AnkiDeck 0.1
import QtQml.Models 2.2

Item { id: dirViewModel
    property alias dirModel: dirModel
    property alias folderModel: folderModel
    property alias showDirs: folderModel.showDirs
    FolderListModel { id: folderModel
        nameFilters: [ "*.*", "*" ]
        showDirs: true
        sortField: FolderListModel.Name
        onCountChanged: {
            own.updateDirModel();
        }
    }

    Repeater {
        model: folderModel
        delegate: Item {
            property string txt: fileName
            onTxtChanged: {
                own.updateDirModel();
            }
        }
    }

    ListModel { id: dirModel }

    FileCommander { id: commander }

    function setPath(path) {
        if (path.substr(0,4) != "file:") { path = "file://"+path; }
        folderModel.folder = path;
    }
    function setFilter(stringArray) {
        folderModel.nameFilters = []
        folderModel.nameFilters = stringArray;
    }

    function newShortNameDeck(fileTarget){
        AnkiDeck.newDeck(fileTarget)
    }

    function newFullPathDeck(fileTarget){}  //AnkiDeck doesn't support

    function removeShortNameFiles(nameList, isDir) {
        var path = own.preparePath();
        var newList = [];
        for(var i=0;i<nameList.length;i++) {
            newList.push(path+nameList[i]);
        }
        return removeFullPathFiles(newList, isDir);
    }
    function removeFullPathFiles(nameList, isDir) {
        var result = true
        for(var i=0;i<nameList.length;i++) {
            result = result && (isDir ? commander.removeDir(nameList[i]) :
                                        commander.remove(nameList[i]));
        }
        return result
    }

    function renameShortNameFile(fileSource, fileTarget, isDir) {
        var path = own.preparePath();
        var target = (isDir ? "" : path) + fileTarget
        return renameFullPathFile(path+fileSource, target, isDir);
    }

    function renameFullPathFile(sourcePath, targetPath, isDir) {
        return isDir ? commander.renameDir(sourcePath, targetPath) :
                       commander.rename(sourcePath, targetPath);
    }

    function copyShortNameFile(fileSource, fileTarget, isDir) {
        var path = own.preparePath();
        return copyFullPathFile(path+fileSource, path+fileTarget, isDir);
    }

    function copyFullPathFile(sourcePath, targetPath, isDir) {
        return isDir ? commander.copyDir(sourcePath, targetPath) :
                       commander.copy(sourcePath, targetPath);
    }

    QtObject { id: own
        function preparePath() {
            var path = folderModel.folder;
            path = path.toString().substr(7);
            if(path[path.length-1] != "/") path = path + "/";
            return path
        }
        function updateDirModel() {
            var count = folderModel.count
            dirModel.clear()
            for(var i=0; i< count; i++) {
                if(folderModel.isFolder(i)) {
                    var names = folderModel.get(i, "fileName").split(".") // only compare middle
                    names.pop()
                    names.shift()
                    if(filterName(names)) {
                        dirModel.append({fileName: folderModel.get(i, "fileName"), orgIndex: i})
                    }
                }
            }
        }
        function filterName(names) {
            for (var i=0;i<folderModel.nameFilters.length;i++) {
                if(folderModel.nameFilters[i]=="*") return true
                var fs = folderModel.nameFilters[i].split(".")
                for(var j=0;j<fs.length;j++) {
                    if (fs[j]=="*") { continue; }
                    for(var k=0;k<names.length;k++) {
                        if(names[k].toUpperCase()==fs[j].toUpperCase()) { return true }
                    }
                }
            }
            return false
        }
    }
}

