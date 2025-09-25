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
            HStack(spacing: 12) {
                Image(systemName: "keyboard")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.blue.gradient)
                Text("Vietnamese Input")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            // Toggle - autosaves
            Toggle(isOn: $model.inputEnabled) {
                Text("Enable Vietnamese Input")
            }
            .toggleStyle(.switch)
            
            // Input method - autosaves
            VStack(alignment: .leading, spacing: 6) {
                Text("Input Method").font(.headline)
                Picker("", selection: $model.inputMethod) {
                    Text("Telex").tag("Telex")
                    Text("VNI").tag("VNI")
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            // Exclude App Picker - autosaves
            VStack(alignment: .leading, spacing: 6) {
                Text("Exclude App").font(.headline)
                Picker("Select an app", selection: $model.selectedAppBundleID) {
                    Text("Select an app").tag("")
                    ForEach(model.runningApps, id: \.bundleIdentifier) { app in
                        if let bundleID = app.bundleIdentifier, !model.excludedApps.contains(bundleID) {
                            Text(app.localizedName ?? "Unknown").tag(bundleID)
                        }
                    }
                }
                .frame(width: 250)
                .onChange(of: model.selectedAppBundleID) {oldValue, newValue in
                    guard !newValue.isEmpty else { return }
                    model.excludedApps.append(newValue)
                    model.selectedAppBundleID = ""
                }
            }
            
            // Reset button
            HStack {
                Spacer()
                Button("Reset") {
                    model.inputEnabled = true
                    model.inputMethod = "Telex"
                    model.excludedApps = []
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .frame(minWidth: 300, minHeight: 0)
        .fixedSize(horizontal: false, vertical: true)
        .padding(25)
    }
}

