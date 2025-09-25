//
//  OpenKeyBridge.h
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenKeyBridge : NSObject

- (instancetype)init;
- (NSString *)processKeyEvent:(int)keyCode modifiers:(int)modifiers currentText:(NSString *)currentText;
- (void)setInputMethod:(int)method;
- (void)resetBuffer;
- (void)setCodeTable:(int)codeTable;
- (void)setFreeMark:(int)freeMark;
- (void)setCheckSpelling:(int)checkSpelling;

@end

NS_ASSUME_NONNULL_END
