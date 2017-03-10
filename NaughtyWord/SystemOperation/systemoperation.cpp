#include "systemoperation.h"
#include <QCoreApplication>

SystemOperation::SystemOperation()
{
}

SystemOperation::~SystemOperation()
{
}

void SystemOperation::restartApp()
{
    QCoreApplication::exit(1000);
}
