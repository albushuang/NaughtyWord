import QtQuick 2.0
import QtWebView 1.0
import "CloudConst.js" as Consts
import "qrc:/../UIControls"
import QtQuick.Window 2.2
import "../generalJS/generalConstants.js" as GeneralConsts
import com.glovisdom.DefinitionVendor 0.1


Item{id:root
    visible: false
    width: parent.width; height: parent.height
    anchors.fill: parent

    property alias driveType: webView.driveType
    property alias ggAuthCode:webView.ggAuthCode
    property alias url: webView.url
    property alias webView: webView

    signal authCodeUpdated(string authCode)
    signal dropboxAuthFinished()
    signal userRejectAuth()
    signal logoutCompelete()
    signal leaveCloudDrive()

    function startLogIn(authUrl){
        webView.startLogIn(authUrl)
    }

    function composeGoogleAuthUrl(){
        return composeGoogleAuthUrl()
    }

    Rectangle{id: barOnLogging;
        color:"#F3F3F3";
        visible: webView.visible
        width: parent.width; height: 50*vRatio
        AutoImage { id: exitButton
            x: textBack.anchors.leftMargin
            anchors.verticalCenter: parent.verticalCenter
            visible: webView.visible;
            height: parent.height*0.8; width: height*rawWidth/rawHeight
            source: "qrc:/pic/insanity_store_back icon colored.png"
            MouseArea { anchors.fill: parent;
                onClicked: leaveCloudDrive()
            }
        }
        Text { id: textBack
            anchors.verticalCenter: exitButton.verticalCenter
            text: qsTr("Back to " + GeneralConsts.appName )
            height: exitButton.height; color: "gray"
            font.pixelSize: 1.5*pFontSize
            fontSizeMode: Text.VerticalFit
            horizontalAlignment: Text.AlignLeft
            anchors.left: exitButton.right; anchors.leftMargin: font.pixelSize/3
            verticalAlignment: Text.AlignVCenter;
        }
    }


    WebView {id: webView;
        y: barOnLogging.height
        width: parent.width;
        height: parent.height-y
        url: ""; visible: true//url != "". Cannot compare url with string directly.
        property string driveType: Consts.googleDrive
        property string ggAuthCode: ""

        onTitleChanged: {
            console.log("WebView title:", title)
            if(driveType == Consts.googleDrive){
                var searchIdx = title.indexOf("code=")
                if(searchIdx != -1){
                    ggAuthCode = title.slice(searchIdx+5)
                    authCodeUpdated(ggAuthCode)
                    root.visible = false
                }
            }else if(driveType == Consts.dropBox){
            //In dropbox case, title cannot tell if the process is over
            }
    // TODO: google user reject to authorize
        }
        onUrlChanged: {
            console.log("WebView url: ", url)
            if(driveType == Consts.googleDrive){
                if(url.toString() == "https://accounts.google.com/ServiceLogin?elo=1"
                        || url.toString().indexOf("Logout2?ilo=1&ils") != -1){
                    stop()
                    logoutCompelete();
                }
            }

            if(driveType == Consts.dropBox){
                var searchIdx = url.toString().indexOf("authorize_submit")
                if(searchIdx != -1){
                    dropboxAuthFinished()
                    root.visible = false
                }
                searchIdx = url.toString().indexOf("https://www.dropbox.com/home")
                if(searchIdx != -1){
                    userRejectAuth()
                    root.visible = false
                }
            }
        }

        function startLogIn(authUrl){
            root.visible = true
            if(authUrl== ""){
                if(driveType == Consts.googleDrive){
                    url = composeGoogleAuthUrl()
                }else if(driveType == Consts.dropBox){
                    console.assert(false, "The authUrl is not defined as expectation")
                }
            }else{
                url = authUrl
            }
            webView.width++;
            webView.width--;
        }

        function composeGoogleAuthUrl(){
            var authUrl = "https://accounts.google.com/o/oauth2/auth";
            authUrl += "?scope=" + Consts.ggScope
            authUrl += "&redirect_uri=" + Consts.ggRedirectUri
            authUrl += "&response_type=" + Consts.ggResponseType
            authUrl += "&approval_prompt=" + Consts.ggApprovalPrompt
            authUrl += "&state=" + Consts.ggState
            authUrl += "&client_id=" + DefinitionVendor.ggClientID
            return authUrl
        }
    }
}



