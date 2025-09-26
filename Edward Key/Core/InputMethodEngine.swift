//
//  InputMethodEngine.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import Foundation
import InputMethodKit
import Carbon
import Cocoa

class InputMethodEngine {
    // MARK: - Singleton
    static let shared = InputMethodEngine()
    
    // MARK: - Properties
    private let bridge: OpenKeyBridge
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var currentApplication: String = ""
    
    // Current text buffer for the active input field
    private var currentText: String = ""
    
    // Configuration
    var isEnabled: Bool = true {
        didSet {
            if let eventTap = eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: isEnabled)
            }
        }
    }
    
    var inputMethod: Int = 0 { // 0 = Telex, 1 = VNI
        didSet {
            bridge.setInputMethod(Int32(inputMethod))
        }
    }
    
    var codeTable: Int = 0 { // 0 = Unicode
        didSet {
            bridge.setCodeTable(Int32(codeTable))
        }
    }
    
    var checkSpelling: Bool = true {
        didSet {
            bridge.setCheckSpelling(checkSpelling ? 1 : 0)
        }
    }
    
    // MARK: - Initialization
    private init() {
        self.bridge = OpenKeyBridge()
        setupEventTap()
    }
    
    deinit {
        stopEventTap()
    }
    
    // MARK: - Event Tap Setup
    private func setupEventTap() {
        // Check accessibility permissions
        guard checkAccessibilityPermissions() else {
            requestAccessibilityPermissions()
            return
        }
        
        // Event types to intercept
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        // Create event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let manager = Unmanaged<InputMethodEngine>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        guard let runLoopSource = runLoopSource else {
            print("Failed to create run loop source")
            return
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        registerForApplicationNotifications()
        
        print("OpenKey event tap setup successfully")
    }
    
    private func stopEventTap() {
        isEnabled = false
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        
        if let eventTap = eventTap {
            CFMachPortInvalidate(eventTap)
        }
 
        eventTap = nil
        runLoopSource = nil
    }
    
    // MARK: - Event Handling
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard isEnabled else { return Unmanaged.passUnretained(event) }
        
        switch type {
        case .keyDown:
            return handleKeyDown(event: event)
        case .flagsChanged:
            return handleFlagsChanged(event: event)
        default:
            return Unmanaged.passUnretained(event)
        }
    }
    
    private func handleKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let modifiers = getModifiersFromEvent(event)
        
        updateCurrentApplication()
        
        // Lấy text đã được xử lý qua OpenKey engine
        let processedText = bridge.processKeyEvent(
            Int32(keyCode),
            modifiers: Int32(modifiers),
            currentText: currentText
        )
        
        // Nếu engine thay đổi text thì apply vào
        if processedText != currentText {
            print("✅ Engine transform: \(currentText) -> \(processedText)")
            handleProcessedText(processedText, originalEvent: event, keyCode: keyCode)
            currentText = processedText
            return nil // suppress event gốc
        }
        
        // Nếu engine không thay đổi thì append ký tự thường
        if let character = getCharacterFromKeyEvent(event, keyCode: keyCode, modifiers: modifiers) {
            currentText += String(character)
            print("👉 Append char: \(character), currentText: \(currentText)")
        }
        
        return Unmanaged.passUnretained(event)
    }
    
//    private func handleKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
//        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
//        let modifiers = getModifiersFromEvent(event)
//
//        updateCurrentApplication()
//
//        // Nếu là ký tự thường thì append vào buffer trước
//        if let character = getCharacterFromKeyEvent(event, keyCode: keyCode, modifiers: modifiers) {
//            currentText += String(character)
//            print("👉 Append char: \(character), currentText: \(currentText)")
//        }
//        
//        // 🔹 MOCK LOGIC: kiểm tra sau khi update currentText
//        var processedText = currentText
//        if currentText.hasSuffix("aa") {
//            processedText = currentText.dropLast(2) + "â"
//        }
//        
//        // Nếu mock thay đổi buffer
//        if processedText != currentText {
//            print("✅ Mocked transform: \(currentText) -> \(processedText)")
//            handleProcessedText(processedText, originalEvent: event, keyCode: keyCode)
//            currentText = processedText
//            return nil // chặn event gốc (nếu muốn suppress)
//        }
//        
//        return Unmanaged.passUnretained(event)
//    }
   
    // MARK: - Character Extraction from CGEvent
    private func getCharacterFromKeyEvent(_ event: CGEvent, keyCode: Int, modifiers: Int) -> Character? {
        let keyboardLayout = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        guard let layoutData = TISGetInputSourceProperty(keyboardLayout, kTISPropertyUnicodeKeyLayoutData) else {
            return nil
        }
        
        let layoutDataRef = Unmanaged<CFData>.fromOpaque(layoutData).takeUnretainedValue()
        let keyLayout = unsafeBitCast(CFDataGetBytePtr(layoutDataRef), to: UnsafePointer<UCKeyboardLayout>.self)
        
        var deadKeyState: UInt32 = 0
        var charCount: Int = 0
        var chars = [UniChar](repeating: 0, count: 4)
        
        let modifierKeyState = (modifiers >> 16) & 0xFF // Convert to UCKeyModifiers
        let keyCode = UInt16(keyCode)
        
        let status = UCKeyTranslate(
            keyLayout,
            keyCode,
            UInt16(kUCKeyActionDown),
            UInt32(modifierKeyState),
            UInt32(LMGetKbdType()),
            UInt32(kUCKeyTranslateNoDeadKeysMask),
            &deadKeyState,
            chars.count,
            &charCount,
            &chars
        )
        
        guard status == noErr, charCount > 0 else {
            return nil
        }
        
        let character = Character(UnicodeScalar(chars[0])!)
        
        // Only return printable characters (ignore control characters)
        return character.isLetter ? character : nil
    }
    
    private func handleFlagsChanged(event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        
        // Handle modifier keys for special functions
        if flags.contains(.maskCommand) {
            // Command key pressed - could be used for temporary disable
            // You can implement toggle functionality here
        }
        
        // Reset buffer on certain modifier combinations
        if flags.contains(.maskControl) || flags.contains(.maskAlternate) {
            resetBuffer()
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    private func handleProcessedText(_ text: String, originalEvent: CGEvent, keyCode: Int) {
        // Delete the previous characters that were replaced
        let charactersToDelete = currentText.count
        deleteCharacters(count: charactersToDelete)
        
        // Insert the processed text
        insertText(text)
        
        // Special handling for backspace and other control keys
        if keyCode == kVK_Delete || keyCode == kVK_ForwardDelete {
            currentText = String(currentText.dropLast())
        }
    }
    
    // MARK: - Text Manipulation
    private func deleteCharacters(count: Int) {
        for _ in 0..<count {
            // Simulate backspace key press
            let source = CGEventSource(stateID: .hidSystemState)
            let deleteDown = CGEvent(keyboardEventSource: source, virtualKey: .init(kVK_Delete), keyDown: true)
            let deleteUp = CGEvent(keyboardEventSource: source, virtualKey: .init(kVK_Delete), keyDown: false)
            
            deleteDown?.post(tap: .cgAnnotatedSessionEventTap)
            deleteUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
    
    private func insertText(_ text: String) {
        guard !text.isEmpty else { return }
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        for character in text {
            let string = String(character)
            
            // Convert string to UTF-16 array (UniChar is UInt16)
            let utf16Chars = Array(string.utf16)
            
            // Create key down event
            if let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
                // Use withUnsafeBufferPointer to get the pointer to UTF-16 chars
                utf16Chars.withUnsafeBufferPointer { buffer in
                    if let baseAddress = buffer.baseAddress {
                        keyDownEvent.keyboardSetUnicodeString(
                            stringLength: utf16Chars.count,
                            unicodeString: baseAddress
                        )
                    }
                }
                keyDownEvent.post(tap: .cgAnnotatedSessionEventTap)
            }
            
            // Create key up event
            if let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
                utf16Chars.withUnsafeBufferPointer { buffer in
                    if let baseAddress = buffer.baseAddress {
                        keyUpEvent.keyboardSetUnicodeString(
                            stringLength: utf16Chars.count,
                            unicodeString: baseAddress
                        )
                    }
                }
                keyUpEvent.post(tap: .cgAnnotatedSessionEventTap)
            }
        }
    }
    
    // MARK: - Application Focus Tracking
    private func registerForApplicationNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidActivate(_ notification: Notification) {
        updateCurrentApplication()
        resetBuffer()
    }
    
    private func updateCurrentApplication() {
        if let frontmostApp = NSWorkspace.shared.frontmostApplication {
            currentApplication = frontmostApp.bundleIdentifier ?? "unknown"
        }
    }
    
    // MARK: - Public Methods
    func resetBuffer() {
        bridge.resetBuffer()
        currentText = ""
    }
    
    func setInputMethod(_ method: InputMethod) {
        inputMethod = method.rawValue
    }
    
    func toggleEnabled() {
        isEnabled.toggle()
    }
    
    func updateSettings(_ settings: OpenKeySettings) {
        inputMethod = settings.inputMethod.rawValue
        codeTable = settings.codeTable.rawValue
        checkSpelling = settings.checkSpelling
    }
    
    // MARK: - Permissions
    private func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Show alert to guide user
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showPermissionsAlert()
        }
    }
    
    private func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "Edward Key needs accessibility permissions to function properly. Please enable it in System Preferences > Security & Privacy > Privacy > Accessibility."
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    // MARK: - Helper Methods
    private func getModifiersFromEvent(_ event: CGEvent) -> Int {
        var modifiers = 0
        let flags = event.flags
        
        if flags.contains(.maskShift) { modifiers |= Int(NSEvent.ModifierFlags.shift.rawValue) }
        if flags.contains(.maskControl) { modifiers |= Int(NSEvent.ModifierFlags.control.rawValue) }
        if flags.contains(.maskAlternate) { modifiers |= Int(NSEvent.ModifierFlags.option.rawValue) }
        if flags.contains(.maskCommand) { modifiers |= Int(NSEvent.ModifierFlags.command.rawValue) }
        if flags.contains(.maskAlphaShift) { modifiers |= Int(NSEvent.ModifierFlags.capsLock.rawValue) }
        
        return modifiers
    }
}

// MARK: - Supporting Enums and Structs
enum InputMethod: Int {
    case telex = 0
    case vni = 1
}

enum CodeTable: Int {
    case unicode = 0
    case tcvn3 = 1
    case vniWindows = 2
}

struct OpenKeySettings {
    let inputMethod: InputMethod
    let codeTable: CodeTable
    let checkSpelling: Bool
    let freeMark: Bool
    
    static let `default` = OpenKeySettings(
        inputMethod: .telex,
        codeTable: .unicode,
        checkSpelling: true,
        freeMark: false
    )
}
