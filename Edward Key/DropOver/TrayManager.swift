//
//  TrayManager.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//


// TrayManager.swift
import SwiftUI
import Combine

class TrayManager: ObservableObject {
    @Published var isTrayVisible = false
    @Published var files: [FileItem] = []
    
    func addToTray(_ file: FileItem) {
        // Avoid duplicates
        if !files.contains(where: { $0.url == file.url }) {
            withAnimation(.spring()) {
                files.append(file)
            }
            NSLog("📁 Added to tray: \(file.name)")
        }
    }
    
    func removeFromTray(_ file: FileItem) {
        withAnimation {
            files.removeAll { $0.id == file.id }
        }
        NSLog("🗑️ Removed from tray: \(file.name)")
    }
    
    func clearTray() {
        withAnimation {
            files.removeAll()
        }
        NSLog("🧹 Cleared all files from tray")
    }
}
