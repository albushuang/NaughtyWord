
function googleSource(key, count, number) {
    return "http://ajax.googleapis.com/ajax/services/search/images?v=1.1&q=\"" +
            key + "\"&start=" + count + "&rsz=" + number;
}

function googleSource(key, extraKey, count, number) {
    return "http://ajax.googleapis.com/ajax/services/search/images?v=1.1&q=\"" +
       extraKey + key + "\"&start=" + count + "&rsz=" + number;
}



