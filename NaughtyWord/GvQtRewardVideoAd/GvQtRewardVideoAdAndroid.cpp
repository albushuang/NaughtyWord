#include "GvQtRewardVideoAdAndroid.h"
#include <QString>
#include <QDebug>

#if (__ANDROID_API__ >= 9)

#include <QAndroidJniObject>
#include <qpa/qplatformnativeinterface.h>
#include <QApplication>
#include "IQtAdMobBanner.h"
#include <QAndroidJniEnvironment>
#include <jni.h>

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdLoaded(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnLoaded();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdEnded(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnVideoEnded();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdLoading(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnLoading();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdWillPresent(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnWillPresent();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdClicked(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnClicked();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdClosed(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnClosed();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdStarted(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnStarted();

        beg++;
    }
}

JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardVideoAdOpened(JNIEnv *env, jobject thiz)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        emit beg.value()->OnOpened();

        beg++;
    }
}

// string and int parameters, how to get?
JNIEXPORT void JNICALL Java_com_glovisdom_NaughtyWord_GvQtRewardVideoAdActivity_onRewardedItemObtained(
        JNIEnv *env, jobject thiz, jstring item, jint amount)
{
    //Q_UNUSED(env)
    Q_UNUSED(thiz)

    const GvQtRewardVideoAdAndroid::TInstances& instances = GvQtRewardVideoAdAndroid::Instances();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator beg = instances.begin();
    GvQtRewardVideoAdAndroid::TInstances::ConstIterator end = instances.end();
    while(beg != end)
    {
        jboolean isCopy;
        const char* utf_string;
        utf_string = env->GetStringUTFChars(item, &isCopy);
        QString qstr(utf_string);
        emit beg.value()->OnObtained(qstr, (int)amount);
        if (isCopy == JNI_TRUE) {
            env->ReleaseStringUTFChars(item, utf_string);
        }
        beg++;
    }
}

#ifdef __cplusplus
}
#endif

int GvQtRewardVideoAdAndroid::s_Index = 0;
GvQtRewardVideoAdAndroid::TInstances GvQtRewardVideoAdAndroid::s_Instances;

GvQtRewardVideoAdAndroid::GvQtRewardVideoAdAndroid()
    : m_Activity(0)
    , m_Index(s_Index++)
{
    s_Instances[m_Index] = this;

    QPlatformNativeInterface* interface = QApplication::platformNativeInterface();
    jobject activity = (jobject)interface->nativeResourceForIntegration("QtActivity");
    if (activity)
    {
        m_Activity = new QAndroidJniObject(activity);
    }
}

GvQtRewardVideoAdAndroid::~GvQtRewardVideoAdAndroid()
{
    s_Instances.remove(m_Index);

    if (m_Activity)
    {
        delete m_Activity;
    }
}

void GvQtRewardVideoAdAndroid::LoadWithUnitId(const QString& unitId)
{
    if (!IsValid())
    {
        return;
    }

    QAndroidJniObject param1 = QAndroidJniObject::fromString(unitId);
    m_Activity->callMethod<void>("LoadRewardedVideoAdWithUnitId", "(Ljava/lang/String;)V", param1.object<jstring>());
}

bool GvQtRewardVideoAdAndroid::IsLoaded() const
{
    if (!IsValid())
    {
        return false;
    }

    bool isLoaded = m_Activity->callMethod<jboolean>("IsRewardedVideoAdLoaded", "()Z");
    return isLoaded;
}

void GvQtRewardVideoAdAndroid::Show()
{    
    if (!IsValid())
    {
        return;
    }

    m_Activity->callMethod<void>("ShowRewardedVideoAd");
}

void GvQtRewardVideoAdAndroid::AddTestDevice(const QString& hashedDeviceId)
{
    if (!IsValid())
    {
        return;
    }

    QAndroidJniObject param1 = QAndroidJniObject::fromString(hashedDeviceId);
    m_Activity->callMethod<void>("AddAdTestDevice", "(Ljava/lang/String;)V", param1.object<jstring>());
}

const GvQtRewardVideoAdAndroid::TInstances& GvQtRewardVideoAdAndroid::Instances()
{
    return s_Instances;
}

bool GvQtRewardVideoAdAndroid::IsValid() const
{
    return (m_Activity != 0 && m_Activity->isValid());
}

#endif // __ANDROID_API__
