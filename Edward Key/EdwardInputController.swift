//
//  EdwardInputController.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import InputMethodKit

class EdwardInputController: IMKInputController {
    
    override init!(server: IMKServer!, delegate: Any!, client inputClient: Any!) {
        super.init(server: server, delegate: delegate, client: inputClient)
        print("override init")
        NSLog("EdwardInputController initialized")
    }
    
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let sender = sender else { return false }
        
        print("event")
        // Use the singleton instance
        return AppModel.shared.handleKeyEvent(event: event, client: sender)
    }
    
    override func activateServer(_ sender: Any!) {
        NSLog("Vietnamese IME activated for client:")
        print("ga")
    }
    
    override func deactivateServer(_ sender: Any!) {
        NSLog("Vietnamese IME deactivated for client:")
        print("ga")
    }
}
