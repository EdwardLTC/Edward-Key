//
//  AppModel.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI
import AppKit
import Combine

class AppModel: ObservableObject {
    @Published var inputEnabled: Bool
    @Published var inputMethod: String
    @Published var excludedApps: [String]
    @Published var runningApps: [NSRunningApplication] = []
    @Published var selectedAppBundleID: String = ""
    
    // MARK: - Init
    init() {
        self.inputEnabled = UserDefaults.standard.bool(forKey: "InputEnabled")
        self.inputMethod = UserDefaults.standard.string(forKey: "InputMethod") ?? "Telex"
        self.excludedApps = UserDefaults.standard.stringArray(forKey: "ExcludedApps") ?? []

        updateRunningApps()
    }
    
    // MARK: - Methods
    func updateRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
}
