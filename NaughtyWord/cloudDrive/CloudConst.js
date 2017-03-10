.pragma library

var googleDrive = "google"
var dropBox = "dropBox"


//Please refer to https://developers.google.com/identity/protocols/OAuth2InstalledApp
var ggApiKey = ""
var ggScope = "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive"
var ggState = "Getting auth code"   //Response message from google
var ggResponseType = "code"
var ggApprovalPrompt = "auto"
var ggRedirectUri = "urn:ietf:wg:oauth:2.0:oob"
var ggTokenValid = 0
var ggHasRefreshToken = 1
var ggNoRefreshToken = 2
var fakeRootId = "sharedRoot-noID-fakeOneID-7859"

var file = "File"
var folder = "Folder"


var titleUpload = qsTr("Upload")
var titleDownload = qsTr("Download")
var titleLinkCopied = qsTr("Link copied")

var disSharingLink = qsTr("Get shared link")
var idSharingLink = 0
