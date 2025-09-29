//
//  OpenKeyBridge.h
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//
//

#ifndef OPENKEYBRIDGE_H
#define OPENKEYBRIDGE_H

#include <ApplicationServices/ApplicationServices.h> // for CGEventRef, CGEventTapProxy, etc.

#ifdef __cplusplus
extern "C" {
#endif

/// Initialize the OpenKey engine.
void OpenKeyInit(void);

/// Callback function for handling keyboard events.
/// Safe to pass to CGEventTapCreate.
CGEventRef OpenKeyCallback(CGEventTapProxy proxy,
                           CGEventType type,
                           CGEventRef event,
                           void *refcon);

void setLanguage(int lang);

void setInputType(int type);

#ifdef __cplusplus
}
#endif

#endif // OPENKEY_H

