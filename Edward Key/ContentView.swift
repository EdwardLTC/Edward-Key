//
//  ContentView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    @State private var runningApps: [NSRunningApplication] = []
    @State private var selectedAppBundleID: String = ""
    @State private var showExcludedAppsModal = false
    
    var body: some View {
        ZStack {
            LiquidGlassBackground()
            
            VStack(spacing: 0) {
                AppHeaderView()
                
                MainContentView(
                    selectedAppBundleID: $selectedAppBundleID,
                    runningApps: $runningApps,
                    showExcludedAppsModal: $showExcludedAppsModal
                )
                .environmentObject(model)
                
                FooterView()
            }
            
        }
        .frame(width: 580, height: 720)
        .sheet(isPresented: $showExcludedAppsModal) {
            ExcludedAppsModalView(model: model)
        }
        .task {
            await Task.yield()
            
            AppObserver.shared.onRunningAppsChange = { apps in
                runningApps = apps
            }
        }
    }
    
    // MARK: - Visual Effect View for macOS
    struct VisualEffectView: NSViewRepresentable {
        let material: NSVisualEffectView.Material
        let blendingMode: NSVisualEffectView.BlendingMode
        
        func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = material
            view.blendingMode = blendingMode
            view.state = .active
            return view
        }
        
        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
            nsView.material = material
            nsView.blendingMode = blendingMode
        }
    }
    
    private struct LiquidGlassBackground: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 28).fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.18),
                            .white.opacity(0.06),
                            .white.opacity(0.12),
                            .white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                RoundedRectangle(cornerRadius: 28).strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.4),
                            .white.opacity(0.15),
                            .white.opacity(0.08),
                            .white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            }
            .shadow(color: .black.opacity(0.12), radius: 40, x: 0, y: 24)
            .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
            .padding(20)
        }
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
