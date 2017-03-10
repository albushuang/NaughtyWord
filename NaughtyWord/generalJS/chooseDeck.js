//.pragma library   //cannot use pragma because library cannot access "Component"

function createMedia(myParent, basePath, prop) {
    if(basePath[basePath.length-1]!="/") basePath += "/"
    var qml
    if (checkAnki(basePath+prop.deck, myParent)) {
        qml = "qrc:/gvComponent/PackMedia.qml"
        prop.deck = basePath + prop.deck
    } else {
        qml = "qrc:/gvComponent/DeckMedia.qml"
    }
    var component = Qt.createComponent(qml);
    return component.createObject(myParent, prop)
}

function checkAnki(deck, myParent) {
    var anki = Qt.createQmlObject('import AnkiPackage 0.1; AnkiPackage { }', myParent);
    var isAnki = anki.isAnkiPackage(deck)
    delete anki
    return isAnki
}
