.pragma library

function isASCII(str, extended) {
    return (extended ? /^[\x00-\xFF]*$/ : /^[\x00-\x7F]*$/).test(str);
}
