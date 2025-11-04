//
//  registerAppToLaunchAtLogin.swift
//  Edward Key
//
//  Created by Thành Công Lê on 3/11/25.
//

import ServiceManagement

func registerAppToLaunchAtLogin(_ enabled: Bool) {
    do {
        if enabled {
            try SMAppService.mainApp.register()
            print("✅ App registered to start at login.")
        } else {
            try SMAppService.mainApp.unregister()
            print("🛑 App unregistered from login items.")
        }
    } catch {
        print("⚠️ Failed to update login item: \(error)")
    }
}

