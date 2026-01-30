import Cocoa

class DropZoneView: NSView {
    var onFileDragEntered: (() -> Void)?
    private var hasTriggeredForCurrentDrag = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }
    
    func resetTrigger() {
        hasTriggeredForCurrentDrag = false
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard sender.draggingPasteboard.types?.contains(.fileURL) == true else {
            return []
        }
        
        let hasFiles = sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true
        ])
        
        if hasFiles && !hasTriggeredForCurrentDrag {
            hasTriggeredForCurrentDrag = true
            onFileDragEntered?()
        }
        
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        hasTriggeredForCurrentDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return false
    }
}
