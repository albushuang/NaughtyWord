import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.2
import "qrc:/../../UIControls"
import "CloudConst.js" as Consts
import "../generalJS/generalConstants.js" as GeneralConsts

Rectangle {id: root
    anchors.fill: parent
    property string driveType
    property bool isForDownload: true   //The view might be used for upload purpose
    property bool viewMyDrive: true // false means view the files from sharing from the other ppl
    property alias folderModel: folderListView.model
    property alias fileModel: fileListView.model
    property bool hasDriveType: driveType == Consts.dropBox || driveType == Consts.googleDrive

    signal driveTypeSelected(string type)
    signal myDriveOrSharingSelected(bool isMyDrive)
    signal fileClicked(int index, variant theItem)
    signal settingsClicked(int index, variant theItem)
    signal uploadBtnClicked(string currFolderId)
    signal leaveCloudDrive()
    signal requestLogout();

    property int fontPointSize: 15
    property int rowSpace: 5
    property int headerHeight: textTitle.contentHeight
    property int eachCellHeight: textTitle.contentHeight*1.5
    property real titleLeftMargin: 30*hRatio

    property string currFolderId: Consts.fakeRootId
    property string currFolderTitle: ""
    property string rootId: Consts.fakeRootId

    Item{id: driveSelection; z: 1
        anchors.fill: parent
        AutoImage {
            anchors.fill: parent
            source: "qrc:/pic/background0.png"
        }
        AutoImage {
            x:0*hRatio; y:262*vRatio
            source: "qrc:/pic/ladderBlue.png"
        }

        AutoImage {z: 1
            width: 341*hRatio; height: 167*vRatio
            x:168; y: 301*vRatio
            source: "qrc:/pic/horizontalLizard.png"
        }


        Button{
            Text {
                x: parent.width/2-width/2
                y: parent.height/2-height/2+100*parent.height/1336
                text: qsTr("Google")
                fontSizeMode: Text.Fit
                font.pointSize: fontPointSize*1.2
                color: "white"
            }
            x: 142*hRatio; y:416*vRatio
            width: 464*hRatio; height: 255*vRatio
            onClicked: {
                driveSelection.visible = false
                driveTypeSelected(Consts.googleDrive)
            }
            style: ButtonStyle{
                background: Image {
                     source: "qrc:/CloudDrive/cloudTopButton.png"
                    }
            }
        }
        Button{
            Text {
                x: parent.width/2-width/2
                y: parent.height/2-height/2-80*parent.height/1336
                text: qsTr("Dropbox")
                fontSizeMode: Text.Fit
                font.pointSize: fontPointSize*1.2
                color: "white"
            }
            x: 142*hRatio; y:655*vRatio
            width: 464*hRatio; height: 255*vRatio
            onClicked: {
                driveSelection.visible = false
                driveTypeSelected(Consts.dropBox)
            }
            style: ButtonStyle{
                background: Image {
                     source: "qrc:/CloudDrive/cloudBottomButton.png"
                }
            }
        }
    }

    Rectangle{ id: title_BG;
        width: parent.width;
        height: parent.height - titleBorderLine.y
        y: titleBorderLine.y;
        color: "#b0eac7"
    }

    Item{ id:titleArea
        visible: hasDriveType
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.7
        height: textTitle.contentHeight
        anchors { bottom: bottomBorderLine.top; bottomMargin: logoutButton.anchors.bottomMargin }
        Text { id: textTitle
            anchors.fill: parent
            text: driveType == Consts.googleDrive ?
                      GeneralConsts.appName + qsTr(" in Google Drive")
                    : GeneralConsts.appName + qsTr(" in Dropbox")
            font.pointSize: fontPointSize
            fontSizeMode: Text.HorizontalFit
            font.italic: true
            font.weight: Font.Thin
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter;
        }
    }

    MultiButtons{id: multiBtns
        y: 5; visible: driveType == Consts.googleDrive
        showTexts: [qsTr("My Cloud Drive"), qsTr("Items shared")]
        enabledArray: [true, isForDownload]
        width: parent.width; height: eachCellHeight*1.2
        fontPointSize:root.fontPointSize
        hightlightColor: "light gray"
        onClicked: {
            myDriveOrSharingSelected(index == 0)
        }
    }

    Component { id: driveDelegate
        Rectangle { id: eachCell; color: "white"; visible: parentId == currFolderId
            width: folderListView.width; height: parentId == currFolderId ? eachCellHeight : -rowSpace;
            property variant parentView: parent.parent
            AutoImage { id: theIcon;
//TODO Shadow: Need folder icon, what icon to be used for files?
                source: title.indexOf(".kmr") == -1 ? "qrc:/pic/cloudDrive_folder.png" : "qrc:/pic/cloudDrive_file.png"
                fillMode: Image.PreserveAspectFit;
                anchors {verticalCenter: parent.verticalCenter}
                height: title.indexOf(".kmr") == -1 ? parent.height*0.6 : parent.height*0.8
                width: height*rawWidth/rawHeight
            }

            FlickableText{
                anchors { verticalCenter: parent.verticalCenter; left: theIcon.right; leftMargin: pFontSize}
                width: menu.x - x - pFontSize; height: eachCell.height*0.9//textObj.contentHeight
                text: title.indexOf(".kmr") == -1 ? title: title.split(".")[0]
                font.pointSize: fontPointSize
                textMouse.onClicked:{
//TODO download whole directory
                    if(title.indexOf(".kmr") == -1){
                        updateCurrFolder(id, title)
                    }else if(isForDownload){
                        fileClicked(index, parentView.model.get(index))
                    }
                }
            }

            Text{id: menu; text: "..."; color: "gray"
                font.pointSize: fontPointSize
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                anchors{right: parent.right; verticalCenter: parent.verticalCenter}
                width: parent.height*2/3; height: width
                transformOrigin: Item.Center; rotation: 90
                MouseArea{anchors.fill: parent;
                    onClicked: settingsClicked(index, parentView.model.get(index))
                }
            }

            Rectangle {color: "#CCCCCC"; anchors.bottom: parent.bottom; height:1; width: parent.width}
        }
    }

    Rectangle{ id: folderHeader
        color: "#F3F3F3"
        width: folderListView.width; height: headerHeight
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: driveType == Consts.googleDrive ? multiBtns.bottom : parent.top
            topMargin: headerHeight/4
        }
        Text{ id: textCurrFolder; anchors.fill: parent
            text: currFolderId == rootId ? qsTr("Folders") : currFolderTitle
            color: "#666666"
            wrapMode: Text.WordWrap;
            font.pointSize: fontPointSize
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter;
        }
        AutoImage{ id: folderBack
            source: "qrc:/pic/insanity_store_back icon colored.png"
            visible: currFolderId != rootId
            x: titleLeftMargin
            height: parent.height*0.8; width: height*rawWidth/rawHeight
            MouseArea{anchors.fill: parent;
                onClicked: {
                    if(currFolderId != rootId){
                        var result  = findModelItemByID(currFolderId)
                        console.assert(result.found, "Cannot find folder model by id" + currFolderId)
                        updateCurrFolder(result.model.parentId, result.model.parentTitle)
                    }
                }
            }
        }
    }

    ListView { id: folderListView
        property string type: Consts.folder
        property int modelCount
        clip: true
        anchors {left:parent.left; leftMargin: 50*hRatio; top: folderHeader.bottom;}
        width: parent.width - x;
        height: (titleBorderLine.y - (multiBtns.y + multiBtns.height)
                 - 2*(folderHeader.anchors.topMargin + folderHeader.height)
                 - folderHeader.anchors.topMargin)/2
        delegate: driveDelegate
        spacing: rowSpace
    }

    Rectangle{ id: fileHeader
        color: folderHeader.color
        width: folderHeader.width; height: folderHeader.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: folderListView.bottom; topMargin: folderHeader.anchors.topMargin
        }
        Text{ id: textFileHeader
            text: qsTr("Files")
            color: textCurrFolder.color
            anchors.fill: parent
            horizontalAlignment: textCurrFolder.horizontalAlignment;
            verticalAlignment: textCurrFolder.verticalAlignment
            fontSizeMode: Text.Fit
            font.pointSize: fontPointSize
        }
    }

    ListView { id: fileListView
        property string type: Consts.file
        property int modelCount
        clip: true
        width: parent.width; height: folderListView.height
        anchors{left:parent.left; leftMargin: 50*hRatio; top: fileHeader.bottom;}
        delegate: driveDelegate
        spacing: rowSpace
    }

    Rectangle{id: bottomBorderLine
        width: parent.width; height:2; color:"light gray" ; visible: hasDriveType
        anchors{
            bottom: isForDownload? logoutButton.top : uploadBtn.top
            bottomMargin: logoutButton.anchors.bottomMargin
        }
    }

    Rectangle{id: titleBorderLine
        width: parent.width; height:2; color:"light gray" ; visible: hasDriveType
        anchors{bottom: titleArea.top; bottomMargin: logoutButton.anchors.bottomMargin}
    }

    Rectangle{id: uploadBtn; visible: !isForDownload && hasDriveType
        width:  textUpload.contentWidth*1.2 > logoutButton.width ?
                   textUpload.contentWidth*1.2 : logoutButton.width
        height: logoutButton.height
        radius: height/3
        anchors{
            right: logoutButton.left; rightMargin: width/6
            bottom: logoutButton.bottom
        }
        border.color: logoutButton.border.color
        border.width: logoutButton.border.width
        Text{ id: textUpload
            anchors.centerIn: parent
            text: qsTr("Upload")
            fontSizeMode: textLogout.fontSizeMode
            font.pointSize: fontPointSize
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
        }
        MouseArea{ anchors.fill: parent
            onClicked: {
                uploadBtnClicked(currFolderId)
            }
        }
    }

    Rectangle{id: logoutButton
        width: textLogout.contentWidth*1.2; height: headerHeight*1.2; visible: hasDriveType
        radius: height/3
        border.color: "gray"
        border.width: 2
        anchors {
            right: parent.right; rightMargin: width/12
            bottom: parent.bottom; bottomMargin: height/5
        }
        Text{ id: textLogout
            anchors.centerIn: parent
            text: qsTr("Logout")
            fontSizeMode: Text.Fit
            font.pointSize: fontPointSize
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter;
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{
                requestLogout();
            }
        }
    }

    function modelCountUnderCurrentFolder(model){
        var totalCount = 0
        for(var i = 0; i < model.count; i++){
            if(model.get(i).parentId == currFolderId){ totalCount++}
        }
        return totalCount
    }

    function updateCurrFolder(id, title){
        currFolderId = id
        currFolderTitle = title
        folderListView.modelCount = modelCountUnderCurrentFolder(folderModel)
        fileListView.modelCount = modelCountUnderCurrentFolder(fileModel)
    }

    function findModelItemByID(id){
        for(var i = 0; i < folderModel.count; i++){
            if(folderModel.get(i).id == id){
                return {found: true, model: folderModel.get(i)}
            }
        }
        return {found: false}
    }
}

