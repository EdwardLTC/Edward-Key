//
//  ShakeDetector.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import Cocoa

class DragZoneDetector {
    private var eventMonitor: Any?
    private var dragMonitor: Any?
    private var isTrackingDrag = false
    private var hasTriggeredForCurrentDrag = false
    private var dropZoneWindow: NSWindow?
    
    var onDragEnterZone: (() -> Void)?
    
    func startDetection() {
        setupDropZone()
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp]) { [weak self] event in
            self?.handleGlobalEvent(event)
        }
        
        dragMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged]) { [weak self] event in
            self?.handleDragMovement(event)
        }
    }
    
    func stopDetection() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = dragMonitor {
            NSEvent.removeMonitor(monitor)
        }
        dropZoneWindow?.close()
        dropZoneWindow = nil
    }
    
    private func setupDropZone() {
        guard let screen = NSScreen.main else { return }
        
        let screenRect = screen.visibleFrame
        let dropZoneWidth: CGFloat = 200
        let dropZoneHeight: CGFloat = screenRect.height
        let dropZoneX = screenRect.maxX - dropZoneWidth
        let dropZoneY = screenRect.minY
        
        dropZoneWindow = NSWindow(
            contentRect: NSRect(x: dropZoneX, y: dropZoneY, width: dropZoneWidth, height: dropZoneHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        dropZoneWindow?.level = .floating
        dropZoneWindow?.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        dropZoneWindow?.isOpaque = false
        dropZoneWindow?.backgroundColor = .clear
        dropZoneWindow?.ignoresMouseEvents = true
        dropZoneWindow?.orderFront(nil)
    }
    
    private func handleGlobalEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            checkDragInitiation()
        case .leftMouseUp:
            resetDetection()
        default:
            break
        }
    }
    
    private func checkDragInitiation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.hasFileInDragPasteboard() {
                self.isTrackingDrag = true
                self.hasTriggeredForCurrentDrag = false
            }
        }
    }
    
    private func hasFileInDragPasteboard() -> Bool {
        let pasteboard = NSPasteboard(name: .drag)
        return pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])
    }
    
    private func handleDragMovement(_ event: NSEvent) {
        guard isTrackingDrag, !hasTriggeredForCurrentDrag else { return }
        
        // Get mouse location in screen coordinates
        let mouseLocation = NSEvent.mouseLocation
        
        // Check if mouse is in the drop zone
        if let dropZone = dropZoneWindow?.frame {
            if dropZone.contains(mouseLocation) {
                hasTriggeredForCurrentDrag = true
                onDragEnterZone?()
            }
        }
    }
    
    private func resetDetection() {
        isTrackingDrag = false
        hasTriggeredForCurrentDrag = false
    }
}
