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
    var model: AppModel! = AppModel.shared
    var statusItem: NSStatusItem?
    var window: NSWindow?
    var menu: NSMenu?
    var mainWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerAppToLaunchAtLogin(true)
        setupStatusBarMenu()
        setupKeyManager()
        setupKeyboardShortCuts()
        setupObserve()
        DropOverDelegate.shared.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.createMainWindow()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        KeyEventManager.shared.stop()
        DropOverDelegate.shared.applicationWillTerminate(notification)
    }
    
    func setupStatusBarMenu() {
        guard let _ = model else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusButtonTitle()
        
        menu = NSMenu()
        
        guard let button = statusItem?.button else { return }
        
        let doubleClickGesture = DoubleClickGestureRecognizer(target: self, action: #selector(handleDoubleClick(_:)))
        doubleClickGesture.numberOfClicksRequired = 2
        button.addGestureRecognizer(doubleClickGesture)
        
        let singleClickGesture = SingleClickGestureRecognizer(target: self, action: #selector(handleSingleClick(_:)))
        singleClickGesture.numberOfClicksRequired = 1
        button.addGestureRecognizer(singleClickGesture)
        
        let excludeItem = NSMenuItem(title: "Exclude Current App", action: #selector(excludeCurrentApp), keyEquivalent: "e")
        excludeItem.target = self
        menu?.addItem(excludeItem)
        
        menu?.addItem(NSMenuItem.separator())
        
        DropOverDelegate.shared.setupStatusBar(menu: menu!)
        
        menu?.addItem(NSMenuItem.separator())
        
        let openItem = NSMenuItem(title: "Open Window", action: #selector(openWindow), keyEquivalent: "o")
        openItem.target = self
        menu?.addItem(openItem)
        
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        updateExcludeMenuItemState(excludeItem)
        
        statusItem?.menu = menu
    }
    
    private func setupObserve() {
        AppObserver.shared.onLangChange = { lang in
            KeyEventManager.shared.changeLanguage(lang: lang)
            self.updateStatusButtonTitle()
        }
        AppObserver.shared.onAppChange = { app in
            KeyEventManager.shared.onActiveAppChange()
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
            NSApp.activate(ignoringOtherApps: true)
            
            if let existingWindow = self.mainWindow, existingWindow.isVisible {
                existingWindow.makeKeyAndOrderFront(nil)
                existingWindow.orderFrontRegardless()
            } else {
                self.mainWindow = nil
                self.createMainWindow()
            }
        }
    }
    
    private func createMainWindow() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let hostingView = NSHostingView(
            rootView: ContentView().environmentObject(AppModel.shared)
        )
        hostingView.autoresizingMask = [.width, .height]
        
        newWindow.contentView = hostingView
        newWindow.title = "Edward Key"
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        newWindow.isMovableByWindowBackground = true
        newWindow.isReleasedWhenClosed = false
        newWindow.delegate = self
        newWindow.center()
        
        self.mainWindow = newWindow
        newWindow.makeKeyAndOrderFront(nil)
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
    
    @objc func toggleLang(){
        model.lang = model.lang == .EN ? .VN : .EN
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
    
    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow === mainWindow {
            // Clean up the view hierarchy before clearing the window reference
            mainWindow?.contentView = nil
            mainWindow = nil
        }
    }
    
    @objc private func handleSingleClick(_ sender: NSClickGestureRecognizer) {
        if let button = statusItem?.button {
            let point = NSPoint(x: button.bounds.midX, y: button.bounds.maxY)
            menu?.popUp(positioning: nil, at: point, in: button)
        }
    }
    
    @objc private func handleDoubleClick(_ sender: NSClickGestureRecognizer) {
        toggleLang()
    }
}


class DoubleClickGestureRecognizer: NSClickGestureRecognizer {
    override func shouldRequireFailure(of otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        return false
    }
    
    override func shouldBeRequiredToFail(by otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        return otherGestureRecognizer is NSClickGestureRecognizer &&
        (otherGestureRecognizer as? NSClickGestureRecognizer)?.numberOfClicksRequired == 1
    }
}

class SingleClickGestureRecognizer: NSClickGestureRecognizer {
    override func shouldRequireFailure(of otherGestureRecognizer: NSGestureRecognizer) -> Bool {
        return otherGestureRecognizer is NSClickGestureRecognizer &&
        (otherGestureRecognizer as? NSClickGestureRecognizer)?.numberOfClicksRequired == 2
    }
}
