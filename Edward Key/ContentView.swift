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
        @StateObject var model = AppModel()
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1)))
                    .blur(radius: 1)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                    .padding()
                
                VStack {
                    ZStack {
                        if selectedTab == 0 {
                            SettingsView()
                                .environmentObject(model)
                                .padding(.horizontal, 24)
                                .frame(maxHeight: 400)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                        removal: .opacity))
                                .matchedGeometryEffect(id: "tab", in: animation)
                        } else {
                            ExcludedAppsView()
                                .environmentObject(model)
                                .padding(.horizontal, 24)
                                .frame(maxHeight: 400)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                                        removal: .opacity))
                                .matchedGeometryEffect(id: "tab", in: animation)
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3), value: selectedTab)
                    
                    Spacer()
                    
                    // Tab bar
                    HStack {
                        tabButton(title: "Settings", image: "gearshape.fill", tag: 0)
                        tabButton(title: "Excluded Apps", image: "app.fill", tag: 1)
                    }
                    .padding()
                }
                .frame(minWidth: 400, minHeight: 450)
            }
        }
        
        @ViewBuilder
        func tabButton(title: String, image: String, tag: Int) -> some View {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                    selectedTab = tag
                }
            } label: {
                VStack {
                    Image(systemName: image)
                        .font(.title2)
                    Text(title)
                        .font(.caption)
                }
                .foregroundColor(selectedTab == tag ? .blue : .gray)
                .padding(8)
                .background(
                    ZStack {
                        if selectedTab == tag {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                                .matchedGeometryEffect(id: "highlight", in: animation)
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
}

#Preview {
    ContentView()
}
