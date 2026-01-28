//
//  AppObserver.swift
//  Edward Key
//
//  Created by Thành Công Lê on 6/10/25.
//

import AppKit
import Combine

import AppKit
import Combine

class AppObserver {
    static let shared = AppObserver()
    private var cancellables = Set<AnyCancellable>()
    private var currentRunningApps: [NSRunningApplication] = []
    
    /// Called when the user switches to another app
    var onAppChange: ((NSRunningApplication) -> Void)?
    
    /// Called when the app language changes
    var onLangChange: ((Lang) -> Void)?
    
    /// Called when the input method changes
    var onInputMethodChange: ((InputMethod) -> Void)?
    
    /// Called when app list changes (launch or terminate) When set, immediately called with current data
    var onRunningAppsChange: (([NSRunningApplication]) -> Void)? {
        didSet {
            onRunningAppsChange?(currentRunningApps)
        }
    }
    
    init() {
        observeFocusedApp()
        observeLanguageChange()
        observeInputMethodChange()
        observeRunningApps()
    }
    
    private func observeFocusedApp() {
        NSWorkspace.shared.notificationCenter.publisher(
            for: NSWorkspace.didActivateApplicationNotification
        )
        .compactMap { $0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication }
        .sink { [weak self] app in
            self?.onAppChange?(app)
        }
        .store(in: &cancellables)
    }
    
    private func observeLanguageChange() {
        AppModel.shared.$lang
            .receive(on: RunLoop.main)
            .sink { [weak self] lang in
                self?.onLangChange?(lang)
            }
            .store(in: &cancellables)
    }
    
    private func observeInputMethodChange(){
        AppModel.shared.$inputMethod
            .receive(on: RunLoop.main)
            .sink { [weak self] method in
                self?.onInputMethodChange?(method)
            }
            .store(in: &cancellables)
    }
    
    private func observeRunningApps() {
        let nc = NSWorkspace.shared.notificationCenter
        
        nc.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateRunningApps()
        }
        
        nc.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateRunningApps()
        }
    
        updateRunningApps()
    }
    
    private func updateRunningApps() {
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
        
        currentRunningApps = apps
        onRunningAppsChange?(apps)
    }
}
