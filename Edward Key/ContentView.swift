//
//  ContentView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        ZStack {
            // Enhanced liquid glass background - FIXED
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 30, x: 0, y: 20
                )
                .overlay(
                    ZStack {
                        LinearGradient(
                            colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1, antialiased: true)
                    }
                )
                .padding(16)
            
            VStack(spacing: 0) {
                // Persistent header for both tabs
                HStack(spacing: 12) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.blue.gradient)
                        .frame(width: 32)
                    
                    Text("Edward Key")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    // Tab indicator pills
                    HStack(spacing: 8) {
                        tabPill(title: "Settings", tag: 0)
                        tabPill(title: "Excluded Apps", tag: 1)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black.opacity(0.1))
                    )
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // Tab content area
                ZStack {
                    if selectedTab == 0 {
                        SettingsView()
                            .environmentObject(model)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95, anchor: .center).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .matchedGeometryEffect(id: "settingsTab", in: animation)
                    } else {
                        ExcludedAppsView()
                            .environmentObject(model)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95, anchor: .center).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .matchedGeometryEffect(id: "excludedTab", in: animation)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3), value: selectedTab)
                .padding(.horizontal, 20)
                .frame(maxHeight: .infinity)
                
                Spacer()
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    func tabPill(title: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                selectedTab = tag
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(selectedTab == tag ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if selectedTab == tag {
                            Capsule()
                                .fill(.blue.gradient)
                                .matchedGeometryEffect(id: "pill", in: animation)
                        } else {
                            Capsule()
                                .fill(.clear)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
        ContentView()
            .environmentObject(AppModel.shared)
            .fixedSize()
            .onAppear {
                DispatchQueue.main.async {
                    NSApp.activate(ignoringOtherApps: true)
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }
            }
}
