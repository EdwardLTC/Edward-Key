//
//  KeyEventManager.swift
//  Edward Key
//
//  Created by Thành Công Lê on 29/9/25.
//

import Cocoa

class KeyEventManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    static let shared = KeyEventManager()
    
    func start() {
        OpenKeyInit()
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.flagsChanged.rawValue),
            callback: myEventCallback,
            userInfo: nil
        )
        
        guard let eventTap = eventTap else {
            print("❌ Failed to create event tap")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func onActiveAppChange(){
        OnActiveAppChanged()
    }
    
    func setInputMethod(method: InputMethod) {
        setInputType(method == .Telex ? 0 : 1)
    }
    
    func changeLanguage(lang: Lang) {
        setLanguage(lang == .EN ? 0 : 1)
    }
    
    func stop() {
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        if let eventTap = eventTap {
            CFMachPortInvalidate(eventTap)
        }
        eventTap = nil
        runLoopSource = nil
    }
    
    private let myEventCallback: CGEventTapCallBack = { proxy, type, event, refcon in
        return OpenKeyCallback(proxy, type, event, refcon)
    }
}

