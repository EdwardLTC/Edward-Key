//
//  ShakeDetector.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import Cocoa

class ShakeDetector {
    private var eventMonitor: Any?
    private var lastDragPosition: CGPoint?
    private var dragStartTime: Date?
    private var movementHistory: [CGVector] = []
    
    private let movementThreshold: CGFloat = 5.0
    private let timeThreshold: TimeInterval = 1.5
    private let requiredDirectionChanges = 3
    
    private var isTrackingDrag = false
    private var hasTriggeredThisDrag = false
    
    var onShakeDetected: (() -> Void)?
    
    func startDetection() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseDown, .leftMouseUp]) { [weak self] event in
            self?.handleGlobalEvent(event)
        }
    }
    
    func stopDetection() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func handleGlobalEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            checkDragInitiation()
        case .leftMouseDragged:
            handleDragEvent(event)
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
                self.hasTriggeredThisDrag = false
            }
        }
    }
    
    private func hasFileInDragPasteboard() -> Bool {
        let pasteboard = NSPasteboard(name: .drag)
        return pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])
    }
    
    private func handleDragEvent(_ event: NSEvent) {
        guard isTrackingDrag, !hasTriggeredThisDrag else { return }
        
        let currentPosition = CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)
        
        if lastDragPosition == nil {
            lastDragPosition = currentPosition
            dragStartTime = Date()
            movementHistory.removeAll()
            return
        }
        
        guard let lastPos = lastDragPosition,
              let startTime = dragStartTime,
              Date().timeIntervalSince(startTime) < timeThreshold else {
            lastDragPosition = currentPosition
            return
        }
        
        let deltaX = currentPosition.x - lastPos.x
        let deltaY = currentPosition.y - lastPos.y
        
        guard abs(deltaX) > 1 || abs(deltaY) > 1 else {
            lastDragPosition = currentPosition
            return
        }
        
        let movementVector = CGVector(dx: deltaX, dy: deltaY)
        movementHistory.append(movementVector)
        
        let maxHistory = 25
        if movementHistory.count > maxHistory {
            movementHistory.removeFirst(movementHistory.count - maxHistory)
        }
        
        if detectShakePattern() {
            hasTriggeredThisDrag = true
            onShakeDetected?()
        }
        
        lastDragPosition = currentPosition
    }
    
    private func detectShakePattern() -> Bool {
        guard movementHistory.count >= 4 else { return false }
        
        var directionChanges = 0
        var lastXDirection: CGFloat = 0
        var lastYDirection: CGFloat = 0
        
        for movement in movementHistory {
            let currentXDirection = movement.dx
            let currentYDirection = movement.dy
        
            if abs(movement.dx) > movementThreshold || abs(movement.dy) > movementThreshold {
                if lastXDirection != 0 && currentXDirection.sign != lastXDirection.sign {
                    directionChanges += 1
                }
                if lastYDirection != 0 && currentYDirection.sign != lastYDirection.sign {
                    directionChanges += 1
                }
            }
            
            lastXDirection = currentXDirection
            lastYDirection = currentYDirection
            
            if directionChanges >= requiredDirectionChanges {
                return true
            }
        }
        
        return false
    }
    
    private func resetDetection() {
        lastDragPosition = nil
        dragStartTime = nil
        movementHistory.removeAll()
        isTrackingDrag = false
        hasTriggeredThisDrag = false
    }
}
