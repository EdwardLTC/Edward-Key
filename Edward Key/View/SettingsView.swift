//
//  SettingsView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "gearshape")
                    .foregroundStyle(.blue)
                Text("Input Settings")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Toggle Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "power.circle")
                        .foregroundStyle(model.inputEnabled ? .green : .secondary)
                    Text("Vietnamese Input")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $model.inputEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                }
                
                Text("Enable or disable Vietnamese input system-wide")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Input Method Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "keyboard").foregroundStyle(.blue)
                    Text("Input Method").font(.headline)
                    Spacer()
                }
                
                Picker("", selection: $model.inputMethod) {
                    Text("Telex").tag("Telex")
                    Text("VNI").tag("VNI")
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
                
                Text("Choose between Telex or VNI input method")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Exclude App Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.blue)
                    Text("Add App Exclusion")
                        .font(.headline)
                    Spacer()
                }
                
                Picker("Select an app to exclude", selection: $model.selectedAppBundleID) {
                    Text("Select an app").tag("")
                    ForEach(model.runningApps, id: \.bundleIdentifier) { app in
                        if let bundleID = app.bundleIdentifier,
                           let appName = app.localizedName,
                           !model.excludedApps.contains(bundleID) {
                            Text(appName).tag(bundleID)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onChange(of: model.selectedAppBundleID) { oldValue, newValue in
                    guard !newValue.isEmpty else { return }
                    withAnimation(.easeInOut) {
                        model.excludedApps.append(newValue)
                        model.selectedAppBundleID = ""
                    }
                }
                
                Text("Selected apps will ignore Vietnamese input")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Reset Button
//            HStack {
//                Spacer()
//                Button(action: {
//                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//                        model.inputEnabled = true
//                        model.inputMethod = "Telex"
//                        model.excludedApps = []
//                    }
//                }) {
//                    HStack {
//                        Image(systemName: "arrow.counterclockwise")
//                        Text("Reset to Defaults")
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
//                    .background(
//                        Capsule()
//                            .fill(.ultraThinMaterial)
//                            .overlay(
//                                Capsule()
//                                    .stroke(.white.opacity(0.1), lineWidth: 1)
//                            )
//                    )
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
        }
        .padding(20)
    }
}
