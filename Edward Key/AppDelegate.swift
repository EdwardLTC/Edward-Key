//
//  AppDelegate.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import Foundation
import Cocoa
import InputMethodKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var model: AppModel!
    
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusBarMenu()
        
        let settings = OpenKeySettings(
            inputMethod: .telex,
            codeTable: .unicode,
            checkSpelling: true,
            freeMark: false
        )
        
        InputMethodEngine.shared.updateSettings(settings)
    }
    
    func setupStatusBarMenu() {
        guard let _ = model else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Vietnamese IME")
            button.action = #selector(statusBarClicked)
            button.target = self
        }
        
        statusItem?.menu = statusMenu()
    }
    
    func statusMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Toggle input
        let toggleItem = NSMenuItem(
            title: model.inputEnabled ? "Disable Input" : "Enable Input",
            action: #selector(toggleInput),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        // Input methods
        menu.addItem(NSMenuItem(title: "Switch to Telex", action: #selector(switchToTelex), keyEquivalent: "1"))
        menu.addItem(NSMenuItem(title: "Switch to VNI", action: #selector(switchToVNI), keyEquivalent: "2"))
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    // MARK: - Status Bar Actions
    @objc func statusBarClicked() { }
    
    @objc func toggleInput() {
        model.inputEnabled.toggle()
        statusItem?.menu = statusMenu()
    }
    
    @objc func switchToTelex() {
        model.inputMethod = "Telex"
    }
    
    @objc func switchToVNI() {
        model.inputMethod = "VNI"
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

