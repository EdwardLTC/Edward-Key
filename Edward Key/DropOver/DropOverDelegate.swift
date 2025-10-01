//
//  DropOverDelegate.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//


import Cocoa
import SwiftUI

class DropOverDelegate{
    static let shared = DropOverDelegate()
    
    private var shakeDetector: ShakeDetector!
    private var trayWindow: NSWindow!
    private var trayManager = TrayManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupShakeDetection()
        setupTrayWindow()
    }
    
    func setupStatusBar(menu: NSMenu) {
        let showItem = NSMenuItem(title: "Show Tray", action: #selector(showTray), keyEquivalent: "t")
        showItem.target = self
        menu.addItem(showItem)
        
        let hideItem = NSMenuItem(title: "Hide Tray", action: #selector(hideTray), keyEquivalent: "h")
        hideItem.target = self
        menu.addItem(hideItem)
    }
    
    private func setupShakeDetection() {
        shakeDetector = ShakeDetector()
        shakeDetector.onShakeDetected = { [weak self] in
            self?.openTrayForFileDrop()
        }
        shakeDetector.startDetection()
    }
    
    private func setupTrayWindow() {
        let contentView = FloatingTrayView(trayManager: trayManager, onCloseTray: { [weak self] in
            self?.hideTray()
        })
        
        trayWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        trayWindow.title = "File Tray"
        trayWindow.level = .floating
        trayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        trayWindow.isReleasedWhenClosed = false
        trayWindow.isOpaque = false
        trayWindow.backgroundColor = .clear
        trayWindow.hasShadow = true
        trayWindow.ignoresMouseEvents = false
        trayWindow.hidesOnDeactivate = false
        trayWindow.registerForDraggedTypes([.fileURL])
        
        let hostingController = NSHostingController(rootView: contentView)
        trayWindow.contentViewController = hostingController
        
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x = screenRect.maxX - 340
            let y = screenRect.maxY - 470
            trayWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        trayWindow.orderOut(nil)
    }
    
    private func openTrayForFileDrop() {
        if (!AppModel.shared.isEnableDropOver){ return }
        
        DispatchQueue.main.async {
            if !self.trayManager.isTrayVisible {
                self.showTray()
            }
            self.trayWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        }
    }
    
    @objc func showTray() {
        trayWindow.makeKeyAndOrderFront(nil)
        trayManager.isTrayVisible = true
    }
    
    @objc func hideTray() {
        trayWindow.orderOut(nil)
        trayManager.isTrayVisible = false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        shakeDetector.stopDetection()
    }
}
