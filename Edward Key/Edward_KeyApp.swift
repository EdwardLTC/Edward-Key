//
//  Edward_KeyApp.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

@main
struct Edward_KeyApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow
    @State private var windowOpen = false
    
    init() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if !trusted {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                NSApp.terminate(nil)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup("Edward Key") {
            ContentView()
                .environmentObject(AppModel.shared)
                .fixedSize()
                .onAppear {
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                        NSApp.windows.first?.makeKeyAndOrderFront(nil)
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Window") {
                    openMainWindow()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
    
    func openMainWindow() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            
            // Try to find and focus existing window
            for window in NSApp.windows {
                if window.title == "Edward Key" {
                    window.makeKeyAndOrderFront(nil)
                    return
                }
            }
            
            // If no window found, use SwiftUI's openWindow action
            openWindow(id: "main")
        }
    }
    
}
