//
//  FloatingTrayView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct FloatingTrayView: View {
    @ObservedObject var trayManager: TrayManager
    @State private var isDropTargeted = false
    @State private var isHovered = false
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text("File Tray")
                        .font(.system(size: 16, weight: .semibold))
                    
                    if !trayManager.files.isEmpty {
                        Text("\(trayManager.files.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.blue))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if !trayManager.files.isEmpty {
                        Button("Clear All") {
                            withAnimation(.spring(response: 0.3)) {
                                trayManager.clearTray()
                                onCloseTray?()
                            }
                        }
                        .buttonStyle(TrayButtonStyle())
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            onCloseTray?()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(TrayButtonStyle())
                    .help("Close Tray")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Content Area
            if trayManager.files.isEmpty {
                EmptyTrayView(isTargeted: isDropTargeted)
                    .frame(maxHeight: .infinity)
            } else {
                FilesListView(trayManager: trayManager, onCloseTray: onCloseTray)
            }
        }
        .frame(width: 340, height: 480)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isDropTargeted ?
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isDropTargeted ? 3 : 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDropTargeted)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var successCount = 0
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                _ = provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                    if let data = data,
                       let path = String(data: data, encoding: .utf8),
                       let url = URL(string: path) {
                        
                        DispatchQueue.main.async {
                            let fileItem = FileItem(
                                name: url.lastPathComponent,
                                type: url.pathExtension,
                                url: url
                            )
                            withAnimation(.spring(response: 0.3)) {
                                trayManager.addToTray(fileItem)
                            }
                            successCount += 1
                        }
                    }
                }
            }
        }
        
        return successCount > 0
    }
}

struct EmptyTrayView: View {
    let isTargeted: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "tray")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(
                    isTargeted ?
                    LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom) :
                    LinearGradient(colors: [.secondary, .secondary.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
                .symbolEffect(.bounce, value: isTargeted)
            
            VStack(spacing: 12) {
                Text("Drop Files Here")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isTargeted ? .blue : .primary)
                
                Text("Drag and drop files anywhere in this tray\nor shake files to open this tray")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? Color.blue.opacity(0.08) : Color.clear)
                .padding(8)
        )
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTargeted)
    }
}

struct FilesListView: View {
    @ObservedObject var trayManager: TrayManager
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(trayManager.files) { file in
                    TrayFileItemView(file: file, trayManager: trayManager, onCloseTray: onCloseTray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.never)
    }
}

struct TrayFileItemView: View {
    let file: FileItem
    @ObservedObject var trayManager: TrayManager
    @State private var isHovered = false
    @State private var isBeingDragged = false
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // File Icon
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // File Info
            VStack(alignment: .leading, spacing: 3) {
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(file.type.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(Color.secondary.opacity(0.15)))
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 6) {
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([file.url])
                }) {
                    Image(systemName: "folder")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(isHovered ? .blue : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Show in Finder")
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        trayManager.removeFromTray(file)
                        if trayManager.files.isEmpty {
                            onCloseTray?()
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isHovered ? .red : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Remove from tray")
            }
            .opacity(isHovered ? 1 : 0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? Color.blue.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovered ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isBeingDragged ? 0.98 : 1.0)
        .opacity(isBeingDragged ? 0.6 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onDrag {
            isBeingDragged = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3)) {
                    trayManager.removeFromTray(file)
                    if trayManager.files.isEmpty {
                        onCloseTray?()
                    }
                }
            }
            
            return NSItemProvider(object: file.url as NSURL)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isBeingDragged)
    }
}

// Custom Button Style
struct TrayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.secondary)
            .padding(6)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.secondary.opacity(0.2) : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
