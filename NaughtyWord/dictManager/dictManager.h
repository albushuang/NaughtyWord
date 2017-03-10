#ifndef DICT_MANAGER_H
#define DICT_MANAGER_H

#include <QObject>
#include <QString>


class DictManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString dictPackage READ dictPackage WRITE setDictPackage)
    Q_PROPERTY(QString unPackRemove READ unPackRemove WRITE unPackRemovePackage)

public:
    DictManager(); // no parameter is allowed
    ~DictManager();
    QString dictionary() const;
    QString dictPackage() const;
    QString unPackRemove() const { return ""; }

public Q_SLOTS:
    void setDictPackage(QString const);
    bool startUnpack();
    bool unPackRemovePackage(QString);
    bool removePackage(QString);
    bool removeDictionary(QString);

Q_SIGNALS:
    void unpackDone();
    void unPackRemoveDone();
    void removeDictDone();

private slots:


private:
    QString m_packagePath;
};

#endif // DICT_MANAGER_H


