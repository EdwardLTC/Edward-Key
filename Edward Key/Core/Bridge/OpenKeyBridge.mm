//
//  OpenKeyBridge.mm
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

#import "OpenKeyBridge.h"
#import "Engine.h"
#import <Cocoa/Cocoa.h>

// Định nghĩa các biến global mà Engine.h yêu cầu
int vLanguage = 1; // 1 = Vietnamese
int vInputType = 0; // 0 = Telex
int vFreeMark = 0;
int vCodeTable = 0; // 0 = Unicode
int vSwitchKeyStatus = 0;
int vCheckSpelling = 1;
int vUseModernOrthography = 1;
int vQuickTelex = 0;
int vRestoreIfWrongSpelling = 0;
int vFixRecommendBrowser = 0;
int vUseMacro = 0;
int vUseMacroInEnglishMode = 0;
int vAutoCapsMacro = 0;
int vUseSmartSwitchKey = 0;
int vUpperCaseFirstChar = 0;
int vTempOffSpelling = 0;
int vAllowConsonantZFWJ = 0;
int vQuickStartConsonant = 0;
int vQuickEndConsonant = 0;
int vRememberCode = 0;
int vOtherLanguage = 0;
int vTempOffOpenKey = 0;

@interface OpenKeyBridge () {
    void *_engine;
    std::wstring _currentBuffer;
}
@end

@implementation OpenKeyBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        _engine = vKeyInit(); // Khởi tạo engine
    }
    return self;
}

- (void)dealloc {
    // Engine không có hàm cleanup
}

- (NSString *)processKeyEvent:(int)keyCode modifiers:(int)modifiers currentText:(NSString *)currentText {
    // Chuyển currentText sang wstring
    std::string currentTextStd = [currentText UTF8String];
    _currentBuffer = utf8ToWideString(currentTextStd);
    
    // Tạo sự kiện bàn phím với trạng thái KeyDown
    vKeyEvent event = Keyboard;
    vKeyEventState state = KeyDown;
    
    // Xác định trạng thái caps lock và control keys
    Uint8 capsStatus = (modifiers & NSEventModifierFlagCapsLock) ? 1 : 0;
    bool otherControlKey = (modifiers & (NSEventModifierFlagControl | NSEventModifierFlagOption | NSEventModifierFlagCommand)) ? true : false;
    
    // Gọi engine để xử lý sự kiện
    vKeyHandleEvent(event, state, (Uint16)keyCode, capsStatus, otherControlKey);
    
    // Chuyển kết quả từ wstring sang NSString
    std::string resultUtf8 = wideStringToUtf8(_currentBuffer);
    NSString *result = [NSString stringWithUTF8String:resultUtf8.c_str()];
    
    return result ? result : @"";
}

- (void)setInputMethod:(int)method {
    vInputType = method;
}

- (void)setCodeTable:(int)codeTable {
    vCodeTable = codeTable;
}

- (void)setFreeMark:(int)freeMark {
    vFreeMark = freeMark;
}

- (void)setCheckSpelling:(int)checkSpelling {
    vCheckSpelling = checkSpelling;
}

- (void)resetBuffer {
    startNewSession(); // Bắt đầu phiên gõ mới
    _currentBuffer.clear();
}

@end
