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
    
    @Published var lang: Lang {
        didSet {
            UserDefaults.standard.setEnumValue(lang, forKey: "Lang")
            KeyEventManager.shared.changeLanguage(lang: lang)
        }
    }
    
    @Published var inputMethod: InputMethod {
        didSet {
            UserDefaults.standard.set(inputMethod, forKey: "InputMethod")
            KeyEventManager.shared.setInputMethod(type: inputMethod == .Telex ? 0 : 1)
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
        self.lang = UserDefaults.standard.enumValue(forKey: "Lang") ?? .EN
        self.inputMethod = UserDefaults.standard.enumValue(forKey: "InputMethod") ?? .Telex
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

enum Lang: String, Codable {
    case EN = "English"
    case VN = "Vietnamese"
}

enum InputMethod: String, Codable {
    case Telex = "Telex"
    case VNI = "VNI"
}

extension UserDefaults {
    func enumValue<T: RawRepresentable>(forKey key: String) -> T? where T.RawValue == String {
        if let rawValue = string(forKey: key) {
            return T(rawValue: rawValue)
        }
        return nil
    }
    
    func setEnumValue<T: RawRepresentable>(_ value: T, forKey key: String) where T.RawValue == String {
        set(value.rawValue, forKey: key)
    }
}
