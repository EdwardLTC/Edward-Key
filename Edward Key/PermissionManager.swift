//
//  PermissionManager.swift
//  Edward Key
//
//  Created by Thành Công Lê on 26/9/25.
//

import Foundation

import Cocoa

class PermissionManager {
    static func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    static func checkInputMonitoringPermission() -> Bool {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        guard let prefs = CFPreferencesCopyAppValue("kTCCServiceInputMonitoring" as CFString, "com.apple.TCC" as CFString) as? [String: Any] else {
            return false
        }
        return prefs.keys.contains(bundleID)
    }
    
    static func showPermissionGuide() {
        let alert = NSAlert()
        alert.messageText = "Cấp quyền cho bộ gõ tiếng Việt"
        alert.informativeText = """
        Để bộ gõ hoạt động, bạn cần cấp các quyền sau:
        
        1. Mở System Preferences > Security & Privacy > Privacy
        2. Chọn Accessibility và tick vào ứng dụng này
        3. Chọn Input Monitoring và thêm ứng dụng vào danh sách
        """
        alert.addButton(withTitle: "Mở System Preferences")
        alert.addButton(withTitle: "Đóng")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
