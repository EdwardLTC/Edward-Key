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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "app.badge.checkmark")
                    .foregroundStyle(.blue)
                Text("Excluded Applications")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 8)
            
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
            
            Spacer()
            
            Text("Excluded apps will not use Vietnamese input methods")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(20)
    }
}
