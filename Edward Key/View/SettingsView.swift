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
            HeaderView()
            
            ToggleCardView()
            
            InputMethodCardView()
            
            EngineStatusView()
        }
        .padding(20)
    }
}

// MARK: - Header View
private struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "gearshape")
                .foregroundStyle(.blue)
            Text("Input Settings")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Toggle Card View
private struct ToggleCardView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        CardContainer {
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
        }
    }
}

// MARK: - Input Method Card View
private struct InputMethodCardView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        CardContainer {
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
        }
    }
}
// MARK: - Engine Status View
private struct EngineStatusView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "engine.combustion")
                        .foregroundStyle(.orange)
                    Text("Engine Status")
                        .font(.headline)
                    Spacer()
                    
                    StatusIndicator(isActive: model.inputEnabled)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Method")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.inputMethod)
                            .font(.system(.body, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Excluded Apps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(model.excludedApps.count)")
                            .font(.system(.body, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                }
                
                if !model.inputEnabled {
                    Text("Vietnamese input is currently disabled")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text("Engine is ready for Vietnamese input")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
