#ifndef SDictLookUpTool_H
#define SDictLookUpTool_H

#include "sDictLookup.h"

#define TO_UL_SHIFT(x, y) ((unsigned long)(x) << (y))
#define TO_UL_SHIFT64(x, y) ((quint64)(x) << (y))

#define MAKE_UL_BIG_ENDIAN(x) \
    ( TO_UL_SHIFT((x)[0], 24) + \
      TO_UL_SHIFT((x)[1], 16) + \
      TO_UL_SHIFT((x)[2], 8) + \
      (unsigned long)(x)[3] )

#define MAKE_UL8_BIG_ENDIAN(x) \
    (   TO_UL_SHIFT64((x)[0], 56) + TO_UL_SHIFT64((x)[1], 48) + \
        TO_UL_SHIFT64((x)[2], 40) + TO_UL_SHIFT64((x)[3], 32) + \
        TO_UL_SHIFT64((x)[4], 24) + TO_UL_SHIFT64((x)[5], 16) + \
        TO_UL_SHIFT64((x)[6], 8) + (quint64)(x)[7] )

inline void getOffsetSize(QString &line, int& offsetSize) {
    QStringList list = line.split("=");
    offsetSize = list[1] < "3" ? 4 : 8;
}

void getConfigureValue(QString &line, QString &sameType) {
    sameType = line.split("=")[1];
    if (sameType.endsWith("\n")) sameType.remove(sameType.size()-1, 1);
}


inline bool isLegalPatternH(const unsigned char uc) {
    return (uc >= 'A' && uc <= 'Z') ||
           (uc >= 'a' && uc <= 'z') || uc=='(' || uc=='-' || uc=='.' || uc=='<' ||
           (uc >= '0' && uc <= '9');
}

inline bool isLegalPatternE(const unsigned char uc) {
    return (uc >= 'A' && uc <= 'Z') ||
           (uc >= 'a' && uc <= 'z') || uc == ')' || uc == '>';
}

inline const unsigned char * seekNext0x00(const unsigned char *puc, int limit, int offsetSize) {
    int offset = offsetSize==4 ? 6: 10;
    while(1) {
        if (isLegalPatternE(puc[0]) && puc[1]==0 && puc[offset]==0 && puc[offset+1]==0) {
            if(isLegalPatternH(puc[offset+4])) return puc+offset+4;
        }
        puc++;
        if(--limit<40) { return 0;}
    }
}

inline int saturate0_25(char value) {
    int ret = toupper(value)-'A';
    if (ret<0) ret=0;
    else if (ret>25) ret=25;
    return ret;
}

const long seekBackRange = 512;

char letterNormalize(char ch) {
    char chUpper = toupper(ch);
    if (chUpper<'A') chUpper = 'A';
    if (chUpper>'Z') chUpper = 'Z';
    return chUpper;
}

int getValue(char *str) {
    int v0 = letterNormalize(str[0])-'A';
    int v1 = letterNormalize(str[1])-'A';
    int v2 = letterNormalize(str[2])-'A';
    return abs(v0*26*26+v1*26+v2);
}


int wordRange(const unsigned char *minuend, const unsigned char *subtrahend){
    char m[4], s[4];
    strncpy(m, (const char*)minuend, 3);
    strncpy(s, (const char*)subtrahend, 3);
    int vm = getValue(m), vs = getValue(s);
    return vm-vs;
}

unsigned long proportionalGuess(unsigned long total, const char *key) {
    int max = strlen((char*)key) > 3 ? 3 : strlen((char*)key);
    unsigned long key_estimated=0;
    unsigned long amount = total;
    for (int i=0;i<max;i++) {
        amount = amount/26;
        key_estimated += amount*saturate0_25(key[i]);
    }
    return key_estimated;
}

// assume keyUpper > wordUpper
bool prettyClosed(const unsigned char *pWord, const unsigned char *pKey) {
    return wordRange(pKey, pWord) < 26*1.5;
}

inline long guessOffset(long total,
                        const char *key,
                        QList<indexOffset> &results,
                        bool &closed) {
    unsigned lastOffset = results[results.length()-1].offset;
    char * found = results[results.length()-1].wordFound;
    int range = wordRange((const unsigned char *)key, (const unsigned char *)found);
    if (lastOffset==0) {
        return proportionalGuess((unsigned long)total, key);
    } else if (range < 26*2 && range > 0) {
        return lastOffset-seekBackRange*2;
        closed = true;
    } else {
        char l[4] = {'A', '\0'}, u[4] = {'Z', 'Z', 'Z', '\0' };
        char *lower=l, *upper=u;
        long lOffset = 0, uOffset=total;
        for (int i=0;i<results.length();i++) {
            if (strcasecmp(results[i].wordFound, lower)>0 && strcasecmp(key, results[i].wordFound)>0) {
                lower = results[i].wordFound, lOffset=results[i].offset;
            }
            if (strcasecmp(results[i].wordFound, upper)<0 && strcasecmp(key, results[i].wordFound)<0) {
                upper = results[i].wordFound, uOffset=results[i].offset;
            }
        }
        float range = wordRange((const unsigned char *)upper, (const unsigned char *)lower);
        float range2 = wordRange((const unsigned char *)key, (const unsigned char *)lower);
        long result = lOffset + (uOffset-lOffset)*(range2/range);
        if (abs((long)(result-lastOffset)) < seekBackRange) { result-= seekBackRange*2, closed=true; }
        return result;
    }
}



inline const char * getWordPointer(const char *data, long offset, int &size, int offsetSize) {
    const char *start = data;
    if(offset!=0) {
        start = (char*)seekNext0x00((unsigned char *)data, size, offsetSize);
        size -= (start-data);
    }
    return start;
}

inline const char *readWordFromData(char *buffer, QFile &indexFile, long offset, int &size, int offsetSize) {
    indexFile.seek(offset);
    size = indexFile.read(buffer, seekBackRange);
    return getWordPointer(buffer, offset, size, offsetSize);
}

inline int prepareBuffer(char *target, char *source, int &size, QFile & indexFile) {
    memcpy(target, source, size);
    int read = indexFile.read(target+size, seekBackRange);
    size+=read;
    return read;
}

const int FOUND = 0;
const int NOT_FOUND = -1;

inline int scanUntilFound(const char * &data, int &dataSize,
                          const char *pKey, int kLen,
                          QFile &indexFile,
                          char* bufOrg,
                          int offsetSize) {
    int size = dataSize;
    memcpy(bufOrg, data, size);
    const unsigned char *pNewWord = (const unsigned char *)bufOrg, *pWord;

    while(1) {
        pWord = pNewWord;
        int compare = strncasecmp((char*)pWord, pKey, kLen);
        if (compare==0) {
            data = (char*)pWord, dataSize = size;
            return FOUND;
        } else if (compare>0) {
            return NOT_FOUND;
        }
        pNewWord = seekNext0x00(pWord, size, offsetSize);
        if (pNewWord==0) {
            //qDebug() << "=============read 1===================";
            if (prepareBuffer(bufOrg, (char*)pWord, size, indexFile)==0) {
                return NOT_FOUND;
            }
            pNewWord = (const unsigned char *)bufOrg;
        }
        else {
            size-=(pNewWord-pWord);
        }
    }
}

void appendFound(QList<indexOffset> &results, const char *found, unsigned long offset) {
    indexOffset wordOffset;
    strncpy(wordOffset.wordFound, found, 19);
    wordOffset.offset=offset;
    results.append(wordOffset);
}

QString pureText(QString content) {
    QString phonetic;
    int start = content.indexOf('[');
    int end = content.indexOf(']');
    if (start!=-1 && end !=-1 && end>start) {
        phonetic = content.mid(start+1, end-start-1);
        content.remove(start, end-start+1);
    }
    return "=" + content + "=" + "/" + phonetic + "/";
}

QString mixedContent(QByteArray content, QString type) {
    std::string theType = type.toStdString();
    QString phonetic, meaning, s;
    for (int i=0;i<type.length();i++) {
        int first = content.indexOf('\0');
        if (first!=-1) {
            s = content.mid(0, first+1);
            content.remove(0, first+1);
        }
        else { s = content; }
        switch(theType[i]) {
        case 't': phonetic = s; break;
        case 'm': meaning = s; break;
        }
    }
    return "=" + meaning + "=" + "/" + phonetic + "/";
}

QString readAndCompose(QFile &fDict, sDictIndex index, QString structure) {
    fDict.seek(index.offset);
    if (structure=="m" || structure=="l" || structure=="") {
        return index.word + pureText(fDict.read(index.size));
    }
    else if (structure.contains("t") && structure.contains("m")) {
        return index.word + mixedContent(fDict.read(index.size), structure);
    }
    else if (structure=="g") {} // not supported
}



inline QString testBufferReadIfShort(QByteArray &array, QFile & indexFile, int offsetSize) {
    QString word(array);
    if(word.length()+1+offsetSize+4 >= array.size()) { // ignore the last word in dictionary index, assume file is correct
        array = array + indexFile.read(seekBackRange);
    }
    return QString(array);
}

inline void insertToListBecomeNext(QList<sDictIndex> &list, QByteArray &array, QFile & indexFile, int offsetSize) {
    sDictIndex index;
    index.word = testBufferReadIfShort(array, indexFile, offsetSize);
    const unsigned char *pvocab = (const unsigned char *)array.constData();
    pvocab+=index.word.length()+1;
    if(offsetSize==4) {
        index.offset = MAKE_UL_BIG_ENDIAN(pvocab);
    }
    else {
        index.offset = MAKE_UL8_BIG_ENDIAN(pvocab);
    }
    index.size = MAKE_UL_BIG_ENDIAN(pvocab+offsetSize);
    list.append(index);
    array.remove(0, index.word.length()+1+offsetSize+4);
}

#endif // SDictLookUpTool_H


