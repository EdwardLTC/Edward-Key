//
//  EngineGlobals.cpp
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

#include "EngineGlobals.hpp"
#include "Engine.h"

int vLanguage = 1;              // 0=English, 1=Vietnamese
int vInputType = 0;             // 0=Telex, 1=VNI
int vFreeMark = 0;
int vCodeTable = 0;
int vSwitchKeyStatus = 0;
int vCheckSpelling = 1;
int vUseModernOrthography = 1;
int vQuickTelex = 0;
int vRestoreIfWrongSpelling = 0;
int vFixRecommendBrowser = 1;
int vUseMacro = 1;
int vUseMacroInEnglishMode = 0;
int vAutoCapsMacro = 1;
int vUseSmartSwitchKey = 1;
int vUpperCaseFirstChar = 1;
int vTempOffSpelling = 0;
int vAllowConsonantZFWJ = 1;    // chính là biến bạn bị undefined
int vQuickStartConsonant = 0;
int vQuickEndConsonant = 0;
int vRememberCode = 0;
int vOtherLanguage = 0;
int vTempOffOpenKey = 0;
