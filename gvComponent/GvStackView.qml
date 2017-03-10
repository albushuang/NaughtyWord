import QtQuick 2.4
import QtQuick.Controls 1.3

StackView {
    id: stackView
    readonly property string transitRight : "right"
    readonly property string transitLeft : "left"
    property string direct: transitRight

    delegate:StackViewDelegate {
        pushTransition: StackViewTransition{
            PropertyAnimation {
                id:enterAnimation
                target: enterItem
                property: "x"
                from:own.getTarget(stackView.direct, enterItem)
                to: 0
            }               
        }
        popTransition: StackViewTransition{
            PropertyAnimation{
                id:popAnimation
                target:exitItem
                property:"x"
                from:0
                to: own.getTarget(stackView.direct, enterItem)
            }
        }
    }

    function switchControl(qml,properties,immediate,replace,destroyOnPop,direct){
        var id;
        if(stackView.busy == false){
            stackView.direct= typeof(direct) == "undefined" ? stackView.direct : direct
            id = stackView.push({item: Qt.resolvedUrl(qml),
                                 properties: properties,
                                 immediate: immediate,
                                 replace: replace,  //true,
                                 destroyOnPop: destroyOnPop,})
        }
        return id;
    }

    QtObject { id: own
	    function getTarget(direct, target) {
	        switch(direct){
                case stackView.transitRight:
	               return target.width
                case stackView.transitLeft:
	               return -target.width
	            }
	        return target.width
	    }
    }
}
