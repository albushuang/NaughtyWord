
#include <QtDebug>
#include <assert.h>
#include <QDir>
#include "DefVendor.h"

// the macro can convert compiler defines to string, ex: DEFINES += SYNONYMKEY2=$(ENV_SYN_KEY2), passing SYNONYMKEY2 to WRAP
// will convert SYNONYMKEY2 to string
#define WRAP2(X) #X
#define WRAP1(X) WRAP2(X)
#define WRAP(X) WRAP1(X)


DefVendor::DefVendor() { }

DefVendor::~DefVendor() { }

QString DefVendor::synonymKey1() const {
    return SYNONYMKEY1;
}

QString DefVendor::synonymKey2() const {
    return SYNONYMKEY2;
}

QString DefVendor::synonymKey3() const {
    return SYNONYMKEY3;
}

QString DefVendor::synonymKey4() const {
    return SYNONYMKEY4;
}

QString DefVendor::ggClientID() const {
    return GGCLIENTID;
}

QString DefVendor::ggSecret() const {
    return GGSECRET;
}

QString DefVendor::firebaseUrl() const {
    return FIREBASEURL;
}

