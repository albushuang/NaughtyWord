import QtQuick 2.4
import QtQuick.Controls 1.3
import com.glovisdom.NWPleaseWait 0.1
import "qrc:/gvComponent"
import "qrc:/NWUIControls"

GvStackView {
    id: stackView
    anchors.fill: parent
    property var viewCannotBePoppedByBackKey: []

    Component.onCompleted: {
        NWPleaseWait.parent = stackView
        NWPleaseWait.z = 100
        NWPleaseWait.setAsDefault(application)
    }

    /*When stackView is bust at pushing new view, the system cannot process mouse event. So the system
      queue those mouse events and process those events after pushing new view. Those events will be
      handled by the new views even though mouse gesture(pressed/drag...) was triggered on the old view */
    onBusyChanged: {
        mouseStealer.enabled = busy
    }/*When pushing a view, we do not accept any other mouse event*/
    MouseArea{id: mouseStealer; anchors.fill: parent; z:99
        enabled: stackView.busy
    }

    onDepthChanged: {
        for(var i = 0; i < viewCannotBePoppedByBackKey.length; i++){
            var found = false
            for(var j = 0; j < stackView.depth; j++){
                if(viewCannotBePoppedByBackKey[i] == stackView.get(j, true)){
                    found = true
                }
            }
            if(!found){viewCannotBePoppedByBackKey.splice(i,1)}
        }
    }

    function vtSwitchControl(qml,properties,immediate,replace,destroyOnPop,direct, cannotBePopedByBack) {
        NWPleaseWait.callbackAfterForceRedraw = function(){
            if(stackView.busy == false){
                stackView.direct= typeof(direct) == "undefined" ? stackView.direct : direct
                var thisItem = stackView.push({item: Qt.resolvedUrl(qml), properties: properties,
                                immediate: immediate, replace: replace,  //true,
                                destroyOnPop: destroyOnPop,})
                if(cannotBePopedByBack){
                    viewCannotBePoppedByBackKey.push(thisItem)
                }

                NWPleaseWait.state = "stopped"
                NWPleaseWait.visible = false
                NWPleaseWait.callbackAfterForceRedraw = (function (){return})()
            }
        }
        NWPleaseWait.message = ""
        NWPleaseWait.visible = true;
        NWPleaseWait.state = "running";
        mouseStealer.enabled = true
    }
    function makePreviousVisible() {
        var previous = stackView.get(stackView.depth-2);
        previous.visible = true;
    }

    function makePreviousInvisible () {
        var previous = stackView.get(stackView.depth-2);
        previous.visible = false;
    }
}
