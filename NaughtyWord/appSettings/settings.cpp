#include "appSettings.h"
#include "settingNames.h"

const NameValue initPair[] =
{{APP_INIT, APP_INIT_NUMBER},
 {APP_LANGUAGE, APP_LANGUAGE_DEFAULT},
 {0, 0}};

const NameValue deckPairs[] =
{{DEFAULT_DECK_PATH, DEFAULT_DECK_PATH_NAME},
 {0, 0}};

const NameValue dictPairs[] =
{{DICT_DEFAULT, DICT_DEFAULT_NAME},
 {DICT_DEFAULT_PATH, DICT_DEFAULT_PATH_NAME},
 {0, 0}};

const NameValue ankiPairs[] =
{{ANKI_DEFAULT_PATH, ANKI_DEFAULT_PATH_NAME},
 {0, 0}};


InitSettings settings[] = {
    {APP_NAME, initPair},    
    {DECK_GROUPE, deckPairs},
    {DICT_GROUPE, dictPairs},
    {ANKI_GROUPE, ankiPairs},
//    {FAST_HAND_GROUP, fasthandPairs},
//    {INSANITY_GROUP, insanityPairs},
//    {AUDIO_SETTING_GROUP, audioPairs},
//    {USER_GROUP, userPairs},
//    {CLOUD_DRIVE_GROUP, cloudDrivePairs},
//    {ENGINEERINGSETTING_GROUP, engineeringSettingPairs},
//    {TUTORIAL_GROUP, tutorialPairs},
    { 0, 0 }
};

