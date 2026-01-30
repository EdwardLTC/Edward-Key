//
//  DragZoneDetector.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import Cocoa

class DragZoneDetector {
    private var dropZoneWindow: NSWindow?
    private var dropZoneView: DropZoneView?
    private var mouseDownMonitor: Any?
    private var mouseDragMonitor: Any?
    private var mouseUpMonitor: Any?
    private var isDragging = false
    private var dragStartTime: Date?
    
    var onDragEnterZone: (() -> Void)?
    
    func startDetection() {
        setupDropZone()
        startMonitoring()
    }
    
    func stopDetection() {
        stopMonitoring()
        dropZoneWindow?.close()
        dropZoneWindow = nil
        dropZoneView = nil
    }
    
    private func setupDropZone() {
        guard let screen = NSScreen.main else { return }
        
        let screenRect = screen.visibleFrame
        let dropZoneWidth: CGFloat = 200
        let dropZoneHeight: CGFloat = screenRect.height
        let dropZoneX = screenRect.maxX - dropZoneWidth
        let dropZoneY = screenRect.minY
        
        let windowRect = NSRect(x: dropZoneX, y: dropZoneY, width: dropZoneWidth, height: dropZoneHeight)
        
        dropZoneWindow = NSWindow(
            contentRect: windowRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        dropZoneWindow?.level = .floating
        dropZoneWindow?.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        dropZoneWindow?.isOpaque = false
        dropZoneWindow?.backgroundColor = .clear
        dropZoneWindow?.ignoresMouseEvents = true // Start with ignoring
        
        dropZoneView = DropZoneView(frame: NSRect(origin: .zero, size: windowRect.size))
        dropZoneView?.onFileDragEntered = { [weak self] in
            self?.onDragEnterZone?()
        }
        
        dropZoneWindow?.contentView = dropZoneView
        dropZoneWindow?.orderFront(nil)
    }
    
    private func startMonitoring() {
        // Monitor mouse down
        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            self?.dragStartTime = Date()
            self?.isDragging = false
        }
        
        // Monitor dragging
        mouseDragMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] _ in
            guard let self = self else { return }
            
            // Only check for file drag after a short drag has started
            if !self.isDragging, let startTime = self.dragStartTime, Date().timeIntervalSince(startTime) > 0.15 {
                self.isDragging = true
                
                // Check if it's a file drag
                DispatchQueue.main.async {
                    if self.isFileDragActive() {
                        self.dropZoneWindow?.ignoresMouseEvents = false
                    }
                }
            }
        }
        
        // Monitor mouse up
        mouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] _ in
            self?.isDragging = false
            self?.dragStartTime = nil
            self?.dropZoneWindow?.ignoresMouseEvents = true
            self?.dropZoneView?.resetTrigger()
        }
    }
    
    private func stopMonitoring() {
        if let monitor = mouseDownMonitor {
            NSEvent.removeMonitor(monitor)
            mouseDownMonitor = nil
        }
        if let monitor = mouseDragMonitor {
            NSEvent.removeMonitor(monitor)
            mouseDragMonitor = nil
        }
        if let monitor = mouseUpMonitor {
            NSEvent.removeMonitor(monitor)
            mouseUpMonitor = nil
        }
    }
    
    private func isFileDragActive() -> Bool {
        let pasteboard = NSPasteboard(name: .drag)
        
        // Check for file URLs
        if let types = pasteboard.types, types.contains(.fileURL) {
            return pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])
        }
        
        return false
    }
}
