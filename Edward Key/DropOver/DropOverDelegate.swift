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
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 480),
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
            let x = screenRect.maxX - 360
            let y = screenRect.maxY - 500
            trayWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        trayWindow.alphaValue = 0.0
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
        guard let window = trayWindow else { return }
        
        // Ensure window is properly positioned for animation
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let _ = screenRect.maxX - 340
            let finalY = screenRect.maxY - 480
            
            // Start from slightly off-screen right position
            let startX = screenRect.maxX + 20
            window.setFrameOrigin(NSPoint(x: startX, y: finalY))
        }
        
        window.alphaValue = 0.0
        window.orderFront(nil)
        
        // Animate appearance
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            context.allowsImplicitAnimation = true
            
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                let finalX = screenRect.maxX - 340
                let finalY = screenRect.maxY - 480
                window.setFrameOrigin(NSPoint(x: finalX, y: finalY))
            }
            
            window.animator().alphaValue = 1.0
            
            // Add a subtle scale effect
            if let contentView = window.contentView {
                contentView.layer?.transform = CATransform3DMakeScale(0.95, 0.95, 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSAnimationContext.runAnimationGroup { scaleContext in
                        scaleContext.duration = 0.3
                        scaleContext.timingFunction = CAMediaTimingFunction(name: .easeOut)
                        contentView.animator().layer?.transform = CATransform3DIdentity
                    }
                }
            }
        }
    }
    
    @objc func hideTray() {
        guard let window = trayWindow else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            context.allowsImplicitAnimation = true
            
            // Slide out to the right with fade
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                let endX = screenRect.maxX + 50
                let currentY = window.frame.origin.y
                window.setFrameOrigin(NSPoint(x: endX, y: currentY))
            }
            
            window.animator().alphaValue = 0.0
            
            // Add slight scale down
            if let contentView = window.contentView {
                contentView.animator().layer?.transform = CATransform3DMakeScale(0.98, 0.98, 1.0)
            }
        } completionHandler: {
            window.orderOut(nil)
            // Reset transform for next appearance
            window.contentView?.layer?.transform = CATransform3DIdentity
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        shakeDetector.stopDetection()
    }
}
