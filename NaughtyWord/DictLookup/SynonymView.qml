import QtQuick 2.0

Rectangle {
    property int titlePixelSize;
    property int contentPixelSize;
    property var dataSource;
    property alias synonymModel: synonymView.model
    property string titleColor: "yellow"
    property string contentColor: "white"
    property string classColor: "lightblue"
    anchors.fill: parent;
    color: "transparent"
    width: parent.width; height: parent.height;

    Component { id: synonymDelegate
        Item {
            width: parent.width; height: childrenRect.height+20;
            Text { id: title; font.pixelSize: titlePixelSize; color: titleColor
                text: category; }
            Text { id: synonymList; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                x: 20; anchors { top: title.bottom; margins: 10; }
                //: synonym for a word
                text: qsTr("synonym: "); color: classColor
            }
            Text { id: synonymContent; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                anchors { top: title.bottom; margins: 10; left: synonymList.right; }
                width: parent.width-synonymList.width-synonymList.x; color: contentColor;
                text: synonym;
            }
            Text { id: similarList; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                x: 20; anchors { top: synonymContent.bottom; margins: 10; }
                width: parent.width-x;
                //: similar term for a word
                text: qsTr("similar term: "); color: classColor
            }
            Text { id: similarContent; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                anchors { top: synonymContent.bottom; margins: 10; left: similarList.right }
                width: parent.width-similarList.width-similarList.x; color: contentColor
                text: similar;
            }
            Text { id: relatedList; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                x: 20; anchors { top: similarContent.bottom; margins: 10; }
                //: related term for a word
                text: qsTr("related term: "); color: classColor
            }
            Text { id: relatedContent; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                anchors { top: similarContent.bottom; margins: 10; left: relatedList.right }
                width: parent.width-relatedList.width-relatedList.x; color: contentColor
                text: related;
            }
            Text { id: antonymList; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                x: 20; anchors { top: relatedContent.bottom; margins: 10; }
                //: antonym of a term
                text: qsTr("antonym: "); color: classColor
            }
            Text { id: antonymContent; font.pixelSize: contentPixelSize; wrapMode: Text.Wrap
                anchors { top: relatedContent.bottom; margins: 10; left: antonymList.right }
                width: parent.width-x-antonymList.width-antonymList.x; color: contentColor
                text: antonym;
            }
        }
    }

    ListView { id: synonymView
        anchors {fill: parent; margins:10 }
        delegate: synonymDelegate
    }

    function updateSynonym(model) {
        synonymView.model = model;
    }

    function synonymElement(cg, syn, sim, ret, ant) {
        this.category = cg;
        this.synonym = syn;
        this.similar = sim;
        this.related = ret;
        this.antonym = ant;
    }

    function getCategoryField() { return "category" }
    function getSynonymField() { return "synonym" }
    function getSimilarField() { return "similar" }
    function getRelatedField() { return "related" }
    function getAntonymField() { return "antonym" }
}

