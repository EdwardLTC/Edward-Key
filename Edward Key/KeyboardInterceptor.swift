//
//  KeyboardInterceptor.swift
//  Edward Key
//
//  Created by Thành Công Lê on 26/9/25.
//

import Cocoa

class KeyboardInterceptor {
    private var eventTap: CFMachPort?
    
    func start() {
        let mask = (1 << CGEventType.keyDown.rawValue) |
                   (1 << CGEventType.flagsChanged.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard type == .keyDown else {
                    return Unmanaged.passUnretained(event)
                }
                
                // Chuyển CGEvent sang NSEvent
                if let nsEvent = NSEvent(cgEvent: event) {
                    // Gọi AppModel.shared.handleKeyEvent
                    _ = AppModel.shared.handleKeyEvent(event: nsEvent, client: nil)
                }
                
                // Trả event lại cho hệ thống để xử lý tiếp
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )
        
        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
    }
}
