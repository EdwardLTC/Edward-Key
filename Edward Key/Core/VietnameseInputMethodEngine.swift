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
        // Thiết lập phương thức nhập mặc định (Telex, VNI, etc.)
        openKeyBridge.setInputMethod(0) // 0 = Telex
    }
    
    func handleKeyEvent(event: NSEvent, client: Any) -> Bool {
        guard let keyEvent = event.toKeyEvent() else { return false }
        
        self.currentClient = client
        
        let currentText = getCurrentCompositionText() ?? ""
        let processedText = openKeyBridge.processKeyEvent(
            Int32(keyEvent.keyCode),
            modifiers: Int32(keyEvent.modifiers),
            currentText: currentText
        )
        
        return updateComposition(text: processedText, client: client)
    }
    
    private func getCurrentCompositionText() -> String? {
        guard let client = currentClient as? IMKTextInput else { return nil }
        
//        var range = NSRange(location: NSNotFound, length: 0)
        guard let text = client.attributedSubstring(from: NSRange(location: 0, length: 0)) else {
            return ""
        }
        
        return text.string
    }
    
    private func updateComposition(text: String, client: Any) -> Bool {
        guard let textInput = client as? IMKTextInput else { return false }
        
        // Xử lý kết quả từ OpenKey engine
        if text.isEmpty {
            // Commit text hiện tại và reset
            if let currentText = getCurrentCompositionText(), !currentText.isEmpty {
                textInput.insertText(currentText, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            }
            resetComposition()
            return true
        }
        
        // Update composition
        textInput.setMarkedText(text, selectionRange: NSRange(location: text.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
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
