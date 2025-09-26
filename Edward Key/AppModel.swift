//
//  AppModel.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import AppKit
import Combine
import SwiftUI
import InputMethodKit

class AppModel: ObservableObject {
    
    static let shared = AppModel()
    
    @Published var inputEnabled: Bool {
        didSet {
            UserDefaults.standard.set(inputEnabled, forKey: "InputEnabled")
        }
    }
    
    @Published var inputMethod: String {
        didSet {
            UserDefaults.standard.set(inputMethod, forKey: "InputMethod")
        }
    }
    
    @Published var excludedApps: [String] {
        didSet {
            UserDefaults.standard.set(excludedApps, forKey: "ExcludedApps")
        }
    }
    
    @Published var runningApps: [NSRunningApplication] = []
    @Published var selectedAppBundleID: String = ""
    
    // MARK: - Init
    init() {
        self.inputEnabled = UserDefaults.standard.bool(forKey: "InputEnabled")
        self.inputMethod = UserDefaults.standard.string(forKey: "InputMethod") ?? "Telex"
        self.excludedApps = UserDefaults.standard.stringArray(forKey: "ExcludedApps") ?? []
        
        updateRunningApps()
        
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(
            self,
            selector: #selector(appDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        
        nc.addObserver(
            self,
            selector: #selector(appDidTerminate(_:)),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
    }
    
    func updateRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
    
    @objc private func appDidLaunch(_ notification: Notification) {
        updateRunningApps()
    }
    
    @objc private func appDidTerminate(_ notification: Notification) {
        updateRunningApps()
    }
}
