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
            updateInputEngineState()
        }
    }
    
    @Published var inputMethod: String {
        didSet {
            UserDefaults.standard.set(inputMethod, forKey: "InputMethod")
            updateInputMethod()
        }
    }
    
    @Published var excludedApps: [String] {
        didSet {
            UserDefaults.standard.set(excludedApps, forKey: "ExcludedApps")
        }
    }
    
    @Published var runningApps: [NSRunningApplication] = []
    @Published var selectedAppBundleID: String = ""
    
    // Thêm input engine
    private var inputEngine: VietnameseInputMethodEngine?
    
    // MARK: - Init
    init() {
        self.inputEnabled = UserDefaults.standard.bool(forKey: "InputEnabled")
        self.inputMethod = UserDefaults.standard.string(forKey: "InputMethod") ?? "Telex"
        self.excludedApps = UserDefaults.standard.stringArray(forKey: "ExcludedApps") ?? []
        
        setupInputEngine()
        updateRunningApps()
        
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(self,
                       selector: #selector(appDidLaunch(_:)),
                       name: NSWorkspace.didLaunchApplicationNotification,
                       object: nil)
        
        nc.addObserver(self,
                       selector: #selector(appDidTerminate(_:)),
                       name: NSWorkspace.didTerminateApplicationNotification,
                       object: nil)
    }
    // MARK: - Input Engine Methods
    private func setupInputEngine() {
        inputEngine = VietnameseInputMethodEngine()
        updateInputEngineState()
        updateInputMethod()
    }
    
    private func updateInputEngineState() {
        if inputEnabled {
            // Khởi động engine khi enabled
            print("Vietnamese input engine enabled")
        } else {
            // Tắt engine khi disabled
            print("Vietnamese input engine disabled")
        }
    }
    
    private func updateInputMethod() {
        guard let engine = inputEngine else { return }
        
        switch inputMethod {
        case "Telex":
            engine.switchInputMethod(0) // Telex
        case "VNI":
            engine.switchInputMethod(1) // VNI
        default:
            engine.switchInputMethod(0) // Mặc định Telex
        }
        
        print("Switched to \(inputMethod) input method")
    }
    
    // MARK: - Public Methods để xử lý sự kiện bàn phím
    func handleKeyEvent(event: NSEvent, client: Any) -> Bool {
        guard inputEnabled else { return false }
        
        if let currentApp = NSWorkspace.shared.frontmostApplication,
           let bundleID = currentApp.bundleIdentifier,
           excludedApps.contains(bundleID) {
            return false
        }
        
        return inputEngine?.handleKeyEvent(event: event, client: client) ?? false
    }
    
    // MARK: - Running Apps Methods
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
