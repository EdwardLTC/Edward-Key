//
//  MainContentView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI
import KeyboardShortcuts

struct MainContentView: View {
    @EnvironmentObject var model: AppModel
    @Binding var selectedAppBundleID: String
    @Binding var runningApps: [NSRunningApplication]
    @Binding var showExcludedAppsModal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LanguageShortcutCard()
                        
            AppExclusionCard(
                selectedAppBundleID: $selectedAppBundleID,
                runningApps: runningApps,
                showModal: $showExcludedAppsModal
            )
            
            DropOverCard()
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 28)
    }
}

// MARK: - Language & Shortcut Card
private struct LanguageShortcutCard: View {
    @EnvironmentObject var model: AppModel
    @Namespace private var animation
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Language")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        
                        HStack(spacing: 4) {
                            LanguageToggleButton(
                                title: "VN",
                                isSelected: model.lang == .VN,
                                namespace: animation
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    model.lang = .VN
                                }
                            }
                            
                            LanguageToggleButton(
                                title: "EN",
                                isSelected: model.lang == .EN,
                                namespace: animation
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    model.lang = .EN
                                }
                            }
                        }
                        .padding(4)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.ultraThinMaterial)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .black.opacity(0.08),
                                                .black.opacity(0.03)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                            }
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                        )
                    }
                    
                    Text("Choose your input language system-wide")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .padding(.leading, 30)
                }
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .primary.opacity(0.12),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "command")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Shortcut")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        KeyboardShortcuts.Recorder(for: .toggleLanguage)
                    }
                    
                    Text("Press this shortcut to toggle language quickly")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .padding(.leading, 30)
                }
            }
        }
    }
}

// MARK: - Language Toggle Button
private struct LanguageToggleButton: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .primary.opacity(0.7))
                .frame(width: 50)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isSelected {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .blue.opacity(0.95),
                                                .blue.opacity(0.85),
                                                .blue.opacity(0.9)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.4),
                                                .white.opacity(0.1)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 0.5
                                    )
                            }
                            .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                            .shadow(color: .blue.opacity(0.2), radius: 2, x: 0, y: 1)
                            .matchedGeometryEffect(id: "languageToggle", in: namespace)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.clear)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Drop Over Card
private struct DropOverCard: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Drop Over")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Toggle("", isOn: $model.isEnableDropOver)
                        .toggleStyle(SwitchToggleStyle())
                }
                
                Text("Enable a floating file tray for quick drag & drop across tabs.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .padding(.leading, 30)
            }
        }
    }
}

// MARK: - App Exclusion Card (Combined)
private struct AppExclusionCard: View {
    @EnvironmentObject var model: AppModel
    @Binding var selectedAppBundleID: String
    let runningApps: [NSRunningApplication]
    @Binding var showModal: Bool
    
    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.app.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Add App Exclusion")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }
                    
                    Picker("Select an app to exclude", selection: $selectedAppBundleID) {
                        Text("Select an app to exclude...").tag("")
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
                        
                        Task { @MainActor in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                model.excludedApps.append(newValue)
                            }
                            selectedAppBundleID = ""
                        }
                    }
                    
                    Text("Selected apps will ignore Vietnamese input")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .padding(.leading, 30)
                }
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .primary.opacity(0.12),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                VStack(alignment: .leading, spacing: 12) {
                    Button(action: {
                        showModal = true
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                model.excludedApps.isEmpty ? .green.opacity(0.18) : .orange.opacity(0.18),
                                                model.excludedApps.isEmpty ? .green.opacity(0.1) : .orange.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 42, height: 42)
                                
                                Image(systemName: model.excludedApps.isEmpty ? "checkmark.circle.fill" : "list.bullet.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: model.excludedApps.isEmpty ? [.green, .mint] : [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.excludedApps.isEmpty ? "No Apps Excluded" : "\(model.excludedApps.count) App\(model.excludedApps.count == 1 ? "" : "s") Excluded")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text(model.excludedApps.isEmpty ? "All apps use Vietnamese input" : "Tap to view and manage excluded apps")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
