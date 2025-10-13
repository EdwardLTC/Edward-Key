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
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var model: AppModel!
    var statusItem: NSStatusItem?
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusBarMenu()
        setupKeyManager()
        setupKeyboardShortCuts()
        setupObserve()
        DropOverDelegate.shared.applicationDidFinishLaunching(aNotification)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyEventManager.shared.stop()
        DropOverDelegate.shared.applicationWillTerminate(notification)
    }
    
    func setupStatusBarMenu() {
        guard let _ = model else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusButtonTitle()
        
        let menu = NSMenu()
        let excludeItem = NSMenuItem(title: "Exclude Current App", action: #selector(excludeCurrentApp), keyEquivalent: "e")
        excludeItem.target = self
        updateExcludeMenuItemState(excludeItem)
        menu.addItem(excludeItem)
        
        DropOverDelegate.shared.setupStatusBar(menu: menu)
        
        menu.addItem(NSMenuItem.separator())
        
        let openItem = NSMenuItem(title: "Open Window", action: #selector(openWindow), keyEquivalent: "o")
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func setupObserve() {
        AppObserver.shared.onLangChange = { lang in
            KeyEventManager.shared.changeLanguage(lang: lang)
            self.updateStatusButtonTitle()
        }
        AppObserver.shared.onAppChange = { app in
            if let menu = self.statusItem?.menu,
               let item = menu.items.first(where: { $0.action == #selector(self.excludeCurrentApp) }) {
                self.updateExcludeMenuItemState(item)
            }
        }
        AppObserver.shared.onInputMethodChange = { method in
            KeyEventManager.shared.setInputMethod(method: method)
        }
    }
    
    private func setupKeyManager() {
        KeyEventManager.shared.start()
    }
    
    private func setupKeyboardShortCuts() {
        KeyboardShortcuts.onKeyUp(for: .toggleLanguage) {
            AppModel.shared.lang = AppModel.shared.lang == .EN ? .VN : .EN
        }
    }
    
    private func updateStatusButtonTitle() {
        if let button = statusItem?.button {
            button.title = model.lang == .EN ? "EDK 🇬🇧" : "EDK 🇻🇳"
        }
    }
    
    @objc func openWindow() {
        DispatchQueue.main.async {
            if let existing = self.window {
                existing.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            
            let contentView = ContentView().environmentObject(AppModel.shared)
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            newWindow.center()
            newWindow.setFrameAutosaveName("Main Window")
            newWindow.contentView = NSHostingView(rootView: contentView)
            newWindow.delegate = self
            
            self.window = newWindow
            
            NSApp.setActivationPolicy(.accessory)
            NSApp.activate(ignoringOtherApps: true)
            newWindow.makeKeyAndOrderFront(nil)
            newWindow.orderFrontRegardless()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                newWindow.makeKey()
                newWindow.makeFirstResponder(newWindow.contentView)
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func excludeCurrentApp() {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = focusedApp.bundleIdentifier else {
            return
        }
        
        if AppModel.shared.excludedApps.contains(bundleID) {
            return
        }
        
        AppModel.shared.excludedApps.append(bundleID)
    }
    
    private func updateExcludeMenuItemState(_ item: NSMenuItem) {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = focusedApp.bundleIdentifier else {
            item.isEnabled = false
            item.title = "Exclude Current App"
            return
        }
        
        if AppModel.shared.excludedApps.contains(bundleID) {
            item.isEnabled = false
            item.isHidden = true
            item.title = "Excluded: \(focusedApp.localizedName ?? bundleID)"
        } else {
            item.isEnabled = true
            item.isHidden = false
            item.title = "Exclude \(focusedApp.localizedName ?? "Current App")"
        }
    }
    
}
