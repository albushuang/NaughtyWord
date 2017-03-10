#include "globalBridgeOfImageProvider.h"

extern DbImage *pQQuickImageProvider;

GlobalBridgeOfImageProvider::GlobalBridgeOfImageProvider() { }

GlobalBridgeOfImageProvider::~GlobalBridgeOfImageProvider() { }

int GlobalBridgeOfImageProvider::putInMediaBox(QByteArray& data, const QString& id) {
    return pQQuickImageProvider->putInMediaBox(data, id);
}

bool GlobalBridgeOfImageProvider::removeFromMediaBox(const QString& id) {
    return pQQuickImageProvider->removeFromMediaBox(id);
}

QByteArray* GlobalBridgeOfImageProvider::getFromMediaBox(const QString& id) {
    return pQQuickImageProvider->getFromMediaBox(id);
}
