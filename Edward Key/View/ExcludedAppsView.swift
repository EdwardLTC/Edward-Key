//
//  ExcludedAppsView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct ExcludedAppsView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeaderView()
            
            ExcludeAppCardView()
            
            ListAppExcludedView()
            
            Text("Excluded apps will not use Vietnamese input methods")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
    }
}
// MARK: - Header View
private struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "app.badge.checkmark")
                .foregroundStyle(.blue)
            Text("Excluded Applications")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.bottom, 8)
    }
}
// MARK: - Exclude App Card View
private struct ExcludeAppCardView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.blue)
                    Text("Add App Exclusion")
                        .font(.headline)
                    Spacer()
                }
                
                AppPickerView()
                
                Text("Selected apps will ignore Vietnamese input")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
// MARK: - App Picker View

struct AppPickerView: View {
    @EnvironmentObject var model: AppModel
    
    @State private var runningApps: [NSRunningApplication] = []
    @State private var selectedAppBundleID: String = ""
    @State private var excludedApps: [String] = []
    
    var body: some View {
        Picker("Select an app to exclude", selection: $selectedAppBundleID) {
            Text("Select an app").tag("")
            ForEach(runningApps, id: \.bundleIdentifier) { app in
                if let bundleID = app.bundleIdentifier,
                   let appName = app.localizedName,
                   !model.excludedApps.contains(bundleID) {
                    Text(appName).tag(bundleID)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onChange(of: selectedAppBundleID) { oldValue, newValue in
            guard !newValue.isEmpty else { return }
            withAnimation(.easeInOut) {
                model.excludedApps.append(newValue)
                selectedAppBundleID = ""
            }
        }
        .onAppear {
            updateRunningApps()
            observeRunningApps()
        }
    }
}

extension AppPickerView {
    private func updateRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular && $0.bundleIdentifier != nil }
            .sorted { ($0.localizedName ?? "") < ($1.localizedName ?? "") }
    }
    
    private func observeRunningApps() {
        let nc = NSWorkspace.shared.notificationCenter
        
        nc.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { _ in updateRunningApps() }
        
        nc.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { _ in updateRunningApps() }
    }
}

// MARK: - List App Excluded View
private struct ListAppExcludedView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        if model.excludedApps.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)
                Text("No Apps Excluded")
                    .font(.headline)
                Text("Vietnamese input is enabled for all applications")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(model.excludedApps.count) app(s) excluded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(model.excludedApps, id: \.self) { bundleID in
                            HStack {
                                Image(systemName: "app.dashed")
                                    .foregroundStyle(.orange)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bundleID.components(separatedBy: ".").last?.capitalized ?? bundleID)
                                        .font(.system(size: 13, weight: .medium))
                                    Text(bundleID)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        model.excludedApps.removeAll { $0 == bundleID }
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                                .help("Remove exclusion")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }
}
