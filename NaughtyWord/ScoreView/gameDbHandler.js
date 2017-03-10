.pragma library
.import QtQuick.LocalStorage 2.0 as Sql
var numberOfHighScoreToSave = 5

function getHighScores(keys){
    var highScorers = []

    var dbIdentifier = repareDbIdentifier(keys)
    var db = Sql.LocalStorage.openDatabaseSync(dbIdentifier,"2.0",dbIdentifier + " Local Data",100)

    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Scores(name TEXT, score NUMBER, time NUMBER)');
            var rs = tx.executeSql('SELECT * FROM Scores ORDER BY score DESC');

            for(var i = 0; i < rs.rows.length; i++) {
                highScorers.push({"name":rs.rows.item(i).name, "score":rs.rows.item(i).score, "time":rs.rows.item(i).time})
            }
        }
    )
    return highScorers
}

function updateHighScore(playerName, score, timeDuration, keys){

    var dbIdentifier = repareDbIdentifier(keys)

    var db = Sql.LocalStorage.openDatabaseSync( dbIdentifier,"2.0", dbIdentifier + " Local Data",100)
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS Scores(name TEXT, score NUMBER, time NUMBER)');

            var rs = tx.executeSql('SELECT * FROM Scores ORDER BY score ASC');

            if(rs.rows.length < numberOfHighScoreToSave){
                tx.executeSql('INSERT INTO Scores (name, score, time) VALUES(?, ?, ?)', [ playerName, score, timeDuration]);
            }else{
                for(var i = 0; i < rs.rows.length; i++) {
                    if(rs.rows.item(i).score < score){
                        var deletedItem = rs.rows.item(i)
                        tx.executeSql('DELETE FROM Scores WHERE name="'+deletedItem.name + '" AND score=' +deletedItem.score+' AND time='+deletedItem.time);
                        tx.executeSql('INSERT INTO Scores (name, score, time) VALUES(?, ?, ?)', [ playerName, score, timeDuration ]);
                        break;
                    }
                }
            }

        }
    )
}

function repareDbIdentifier(keys){
    var dbIdentifier = ""
    if(keys.length > 0){
        dbIdentifier += keys[0]
        for(var i = 0 ; i < keys.length; i ++){
            dbIdentifier += "/" + keys[i]
        }
    }
    return dbIdentifier
}

function isNewRecordBy(score, keys){
    var maxNum = numberOfHighScoreToSave
    var highScorers = getHighScores(keys)
    console.assert(highScorers.length <= maxNum, "Exceed maximum number of high score")

    return highScorers.length < maxNum || highScorers[highScorers.length-1].score < score
}

function isBestPersonalScore(playerName, score, keys){
    var result = false
    var foundName= false
    var highScorers = getHighScores(keys)
    for(var i = 0; i< highScorers.length; i++){
        if(highScorers[i].name == playerName){
            result = score > highScorers[i].score
            foundName = true
            break;
        }
    }
    if(!foundName){ result = true}
    return result
}
