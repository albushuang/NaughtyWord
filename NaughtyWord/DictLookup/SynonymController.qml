import QtQuick 2.0

// TODO: one account is limited to 5000 lookups per day, this might be an issue in the future.
Item { id: controller
    property SynonymView view;
    ListModel { id: resultModel }
    SynonymModel { id: model }
    property var searchCallback

    function searchSynonym(key, callback) {
        view.updateSynonym(null);
        resultModel.clear();
        model.searchSynonym(key, own.updateSynonymResult);
        searchCallback = callback;
    }

    function composeSynonym(record) {
        var synonym = "", similar = "", related = "", antonym = "", category = "";
        var sf = view.getSynonymField();
        var sif = view.getSimilarField();
        var cf = view.getCategoryField();
        var af = view.getAntonymField();
        var rf = view.getRelatedField();
        for (var i=0;i<resultModel.count;i++) {
            var obj = resultModel.get(i);
            category += obj[cf] + "##";
            synonym +=  obj[sf] + "##";
            similar +=  obj[sif] + "##";
            related +=  obj[rf] + "##";
            antonym +=  obj[af] + "##";
        }
        record["category"] = category;
        record["synonym"] = synonym;
        record["similar"] = similar;
        record["related"] = related;
        record["antonym"] = antonym;
    }


    function setView(aView) {
        view = aView;
        view.dataSource = controller;
    }

    function get3Synonyms() {
        var synArray = [];
        for (var i=0;i<resultModel.count;i++) {
            var obj = resultModel.get(i);
            if (obj["synonym"] != "") {
                var syn = obj["synonym"].split("|");
                for(var j=0;j<syn.length;j++) {
                    if(syn[j]!="" && syn[j]!=" ") {
                        own.checkAndPush(syn[j], synArray)
                        if(synArray.length>2) return synArray;
                    }
                }
            }
        }
    }

    QtObject { id: own
        function checkAndPush(target, synArray) {
            for (var i=0;i<synArray.length;i++)
            {
                if (synArray[i]==target) return;
            }
            synArray.push(target);
        }
        function updateSynonymResult(jsonSource) {
            for (var i=0; i<jsonSource.count; i++) {
                var syn = ""; var related = "";
                var sim = ""; var ant = "";
                var words = jsonSource.get(i).list.synonyms.split('|');
                for (var j=0;j<words.length; j++) {
                    var keywords = words[j].split('(');
                    if(keywords.length>1) {
                        if (keywords[1] === "similar term)")
                            { if(sim!="") sim += " | "; sim += keywords[0].trim(); }
                        else if (keywords[1] === "related term)")
                            { if(related!="") related += " | "; related += keywords[0].trim(); }
                        else if (keywords[1] === "antonym)")
                            { if(ant!="") ant += " | "; ant += keywords[0].trim(); }
                    } else {
                        if(syn!="") { syn += " | "; } syn += words[j].trim();
                    }
                }
                var element = new view.synonymElement(makeCategory(jsonSource.get(i).list),
                                                      syn, sim,related, ant);
                resultModel.append(element);
            }
            view.updateSynonym(resultModel);
            searchCallback();
        }

        function makeCategory(list) {
            var string;
            switch (list.category) {
            //: a type of word, noun
            case "(noun)": string = qsTr("(noun)"); break;
            //: a type of word, verb
            case "(verb)": string = qsTr("(verb)"); break;
            //: a type of word, adjective
            case "(adj)": string = qsTr("(adj)"); break;
            //: a type of word, adverb
            case "(adv)": string = qsTr("(adv)"); break;
            // prefix, suffix, pronoun, predeterminer, preposition, number, determiner, conjunction
            default: string = list.category; break;
            }
            return string;
        }
    }
}

