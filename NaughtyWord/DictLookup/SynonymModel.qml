import QtQuick 2.0
import com.glovisdom.DefinitionVendor 0.1
import "qrc:/"

Item {
    property var synonymCallback;
    JSONListModel { id: synonymJSON;
        query: "$.response[*]"
        onJsonChanged: {
            synonymCallback(synonymJSON.model);
        }
    }
    function searchSynonym(key, callback) {
        synonymCallback = callback;
        synonymJSON.source = synonymSource(key);
    }
    function synonymSource(key) {
        var index = Math.floor((Math.random() * own.keys.length));
        return "http://thesaurus.altervista.org/thesaurus/v1?language=en_US&key="+own.keys[index]+"&output=json&word="+key;
    }

    QtObject { id: own
        property var keys: [
            DefinitionVendor.synonymKey1,
            DefinitionVendor.synonymKey2,
            DefinitionVendor.synonymKey3,
            DefinitionVendor.synonymKey4
        ]
    }
}

