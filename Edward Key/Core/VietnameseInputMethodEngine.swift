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
    
    init() {
        self.openKeyBridge = OpenKeyBridge()
    }
    
    func handleKeyEvent(event: NSEvent, client: IMKTextInput) -> Bool {
        guard let keyEvent = event.toKeyEvent() else { return false }
        
        let currentText = getCurrentCompositionText(client: client) ?? ""
        let processedText = openKeyBridge.processKeyEvent(
            Int32(keyEvent.keyCode),
            modifiers: Int32(keyEvent.modifiers),
            currentText: currentText
        )
        
        
        return updateComposition(text: processedText, client: client)
    }
    
    private func updateComposition(text: String, client: IMKTextInput) -> Bool {
        if text.isEmpty {
            if let currentText = getCurrentCompositionText(client: client), !currentText.isEmpty {
                client.insertText(currentText, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
            }
            resetComposition()
            return true
        }
        
        client.setMarkedText(text, selectionRange: NSRange(location: text.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        return true
    }
    
    private func getCurrentCompositionText(client: IMKTextInput) -> String? {
        return client.attributedSubstring(from: NSRange(location: 0, length: 0))?.string ?? ""
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
