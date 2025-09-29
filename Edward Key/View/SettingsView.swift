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
            
            Text("© 2025 EdwardLTC. Built upon the original OpenKey by @tuyenvm.")
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
                    Image(systemName: "globe")
                        .foregroundStyle(.blue)
                    Text("Language")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $model.lang) {
                        Text("VN").tag(Lang.VN)
                        Text("EN").tag(Lang.EN)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                Text("Choose your input language system-wide")
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
                    Text("Telex").tag(InputMethod.Telex)
                    Text("VNI").tag(InputMethod.VNI)
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
