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
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    var model: AppModel!
    var statusItem: NSStatusItem?
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBarMenu()
        KeyEventManager.shared.start()
        KeyboardShortcuts.onKeyUp(for: .toggleLanguage) {
            AppModel.shared.lang = AppModel.shared.lang == .EN ? .VN : .EN
        }
        DropOverDelegate.shared.applicationDidFinishLaunching(aNotification)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyEventManager.shared.stop()
        DropOverDelegate.shared.applicationWillTerminate(notification)
    }
    
    func setupStatusBarMenu() {
        guard let _ = model else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "EDK"
        }
        
        let menu = NSMenu()
        DropOverDelegate.shared.setupStatusBar(menu: menu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    // MARK: - Status Bar Actions
    @objc func statusBarClicked() {
    }
    
    @objc func openWindow() {
        if window == nil {
            let contentView = ContentView().environmentObject(AppModel.shared)
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window?.center()
            window?.setFrameAutosaveName("Main Window")
            window?.contentView = NSHostingView(rootView: contentView)
        }
        
        NSApp.setActivationPolicy(.regular) // temporarily show as a UI app
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
