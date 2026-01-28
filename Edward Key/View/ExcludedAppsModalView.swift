//
//  ExcludedAppsModalView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct ExcludedAppsModalView: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            
            VStack(spacing: 0) {
                ModalHeader(model: model, dismiss: dismiss)
                
                if model.excludedApps.isEmpty {
                    EmptyStateView()
                } else {
                    ExcludedAppsListView(model: model)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

// MARK: - Modal Header
private struct ModalHeader: View {
    @ObservedObject var model: AppModel
    let dismiss: DismissAction
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .orange.opacity(0.2),
                                .orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Excluded Applications")
                    .font(.system(size: 20, weight: .bold))
                Text("\(model.excludedApps.count) app\(model.excludedApps.count == 1 ? "" : "s") excluded")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.1),
                                    .white.opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .green.opacity(0.15),
                                .green.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("No Apps Excluded")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Vietnamese input is enabled for all applications")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Excluded Apps List View
private struct ExcludedAppsListView: View {
    @ObservedObject var model: AppModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(model.excludedApps, id: \.self) { bundleID in
                    ExcludedAppRow(bundleID: bundleID, model: model)
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Excluded App Row
private struct ExcludedAppRow: View {
    let bundleID: String
    @ObservedObject var model: AppModel
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .orange.opacity(0.18),
                                .orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)
                
                Image(systemName: "app.dashed")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bundleID.components(separatedBy: ".").last?.capitalized ?? bundleID)
                    .font(.system(size: 15, weight: .semibold))
                Text(bundleID)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    model.excludedApps.removeAll { $0 == bundleID }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .buttonStyle(.plain)
            .help("Remove exclusion")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.08),
                                .white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}
