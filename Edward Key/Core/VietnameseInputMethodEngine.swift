//
//  VietnameseInputMethodEngine.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import Foundation
import InputMethodKit
import Carbon

class VietnameseInputMethodEngine {
    private let openKeyBridge: OpenKeyBridge
    private var currentClient: Any?
    
    init() {
        self.openKeyBridge = OpenKeyBridge()
        openKeyBridge.setInputMethod(0) 
    }
    
    func handleKeyEvent(event: NSEvent, client: Any?) -> Bool {
        guard let keyEvent = event.toKeyEvent() else { return false }
        
        let currentText = getCurrentCompositionText(client: client) ?? ""
        let processedText = openKeyBridge.processKeyEvent(
            Int32(keyEvent.keyCode),
            modifiers: Int32(keyEvent.modifiers),
            currentText: currentText
        )

        
        return updateComposition(text: processedText, client: client)
    }
    
//    private func updateComposition(text: String, client: Any?) -> Bool {
//        guard let textInput = client as? IMKTextInput else { return false }
//        
//        // Xử lý kết quả từ OpenKey engine
//        if text.isEmpty {
//            // Commit text hiện tại và reset
//            if let currentText = getCurrentCompositionText(), !currentText.isEmpty {
//                textInput.insertText(currentText, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
//            }
//            resetComposition()
//            return true
//        }
//        
//        // Update composition
//        textInput.setMarkedText(text, selectionRange: NSRange(location: text.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
//        return true
//    }
    
    private func commitText(_ text: String) {
        print("Commit text \(text)")
        for scalar in text.unicodeScalars {
            let uniChar: UniChar = UInt16(truncatingIfNeeded: scalar.value) // ép kiểu
            let eventDown = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
            eventDown?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [uniChar])
            eventDown?.post(tap: .cghidEventTap)
            
            let eventUp = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)
            eventUp?.keyboardSetUnicodeString(stringLength: 1, unicodeString: [uniChar])
            eventUp?.post(tap: .cghidEventTap)
        }
    }

    private func getCurrentCompositionText(client: Any?) -> String? {
        guard let textInput = client as? IMKTextInput else { return nil }
        return textInput.attributedSubstring(from: NSRange(location: 0, length: 0))?.string ?? ""
    }
    
    private func updateComposition(text: String, client: Any?) -> Bool {
        print("handle \(text)")
        // Nếu có IMKTextInput
        if let textInput = client as? IMKTextInput {
            if text.isEmpty {
                if let currentText = getCurrentCompositionText(client: client), !currentText.isEmpty {
                    textInput.insertText(currentText, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
                }
                resetComposition()
                return true
            }
            
            textInput.setMarkedText(
                text,
                selectionRange: NSRange(location: text.count, length: 0),
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            return true
        }
        
        // Nếu không có client (Event Tap / App background)
        if client == nil {
            commitText(text) // Hàm tự viết để gửi text vào app đang focus
        } else {
            resetComposition()
        }
        
        return true
    }
    
    private func resetComposition() {
        openKeyBridge.resetBuffer()
    }
    
    func switchInputMethod(_ method: Int) {
        openKeyBridge.setInputMethod(Int32(method))
        resetComposition()
    }
}

// Extension để convert NSEvent sang key event format phù hợp
extension NSEvent {
    func toKeyEvent() -> (keyCode: Int, modifiers: Int)? {
        let modifierFlags = self.modifierFlags.rawValue
        let carbonModifiers = modifierFlagsToCarbon(modifierFlags)
        
        return (keyCode: Int(self.keyCode), modifiers: carbonModifiers)
    }
    
    private func modifierFlagsToCarbon(_ flags: UInt) -> Int {
        var carbonFlags = 0
        
        if flags & NSEvent.ModifierFlags.control.rawValue != 0 {
            carbonFlags |= controlKey
        }
        if flags & NSEvent.ModifierFlags.option.rawValue != 0 {
            carbonFlags |= optionKey
        }
        if flags & NSEvent.ModifierFlags.shift.rawValue != 0 {
            carbonFlags |= shiftKey
        }
        if flags & NSEvent.ModifierFlags.command.rawValue != 0 {
            carbonFlags |= cmdKey
        }
        
        return carbonFlags
    }
}
