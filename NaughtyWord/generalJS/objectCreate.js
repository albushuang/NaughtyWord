//.pragma library   //cannot use pragma because library cannot access "Component"

var callerArray = [];

function createComponent(parent, qml, prop, callback) {
    var component = Qt.createComponent(qml);
    callerArray.push({parentComponent: parent, att: prop, comp: component, qmlName: qml, func: callback });

    if (component.status == Component.Ready) {
        finishCreation();
    } else if (component.status == Component.Error) {
        console.log("create component error:",component.errorString());
    } else {
        component.statusChanged.connect(finishCreation);
    }
}

function instantComponent(parent, qml, prop) {
    var component = Qt.createComponent(qml);
    return component.createObject(parent, prop);
}

function finishCreation() {
    for (var i=0; i < callerArray.length;) {
        var component = callerArray[i].comp;
        if (component.status == Component.Ready) {
            var objId = component.createObject(callerArray[i].parentComponent, callerArray[i].att);
            if (objId == null) {
                console.log("Error creating object");
            } else {
                if(typeof(callerArray[i].func) != "undefined") {
                    callerArray[i].func(true, objId, callerArray[i].qmlName);
                } else {
                    callerArray[i].parentComponent.constructFinished(true, objId, callerArray[i].qmlName);
                }
            }
            callerArray.splice(i, 1);
        } else if (component.status == Component.Error) {
            console.assert(false, "Error loading component:" + callerArray[i].qmlName +"; error message:", component.errorString());
            callerArray[i].parentComponent.constructFinished(false, "", callerArray[i].qmlName);
            callerArray[i].splice(i, 1);
        } else { i++ }
    }
}
