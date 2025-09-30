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
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("File Tray")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !trayManager.files.isEmpty {
                    Button("Clear All") {
                        trayManager.clearTray()
                        onCloseTray?()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                }
                
                Button(action: {
                    onCloseTray?()
                }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Close Tray")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            DropZoneView(isTargeted: $isDropTargeted, trayManager: trayManager).frame(height: 80)
            
            Divider()
            
            if trayManager.files.isEmpty {
                EmptyTrayView()
            } else {
                FilesListView(trayManager: trayManager,onCloseTray: onCloseTray)
            }
        }
        .frame(width: 320, height: 450)
        .background(Color(.windowBackgroundColor).opacity(0.95))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isDropTargeted ? Color.blue : Color.white.opacity(0.2), lineWidth: isDropTargeted ? 3 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isDropTargeted)
    }
}

struct DropZoneView: View {
    @Binding var isTargeted: Bool
    @ObservedObject var trayManager: TrayManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isTargeted ? "tray.fill" : "tray")
                .font(.system(size: 24))
                .foregroundColor(isTargeted ? .blue : .secondary)
            
            Text(isTargeted ? "Drop files here..." : "Drop zone")
                .font(.subheadline)
                .foregroundColor(isTargeted ? .blue : .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
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
                            trayManager.addToTray(fileItem)
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
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Tray is Empty")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("Drop files here or shake files to open this tray")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FilesListView: View {
    @ObservedObject var trayManager: TrayManager
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(trayManager.files) { file in
                    TrayFileItemView(file: file, trayManager: trayManager, onCloseTray: onCloseTray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

struct TrayFileItemView: View {
    let file: FileItem
    @ObservedObject var trayManager: TrayManager
    @State private var isHovered = false
    @State private var isBeingDragged = false
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(file.type.uppercased())
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                NSWorkspace.shared.activateFileViewerSelecting([file.url])
            }) {
                Image(systemName: "folder")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Show in Finder")
            
            Button(action: {
                withAnimation {
                    trayManager.removeFromTray(file)
                    if trayManager.files.isEmpty {
                        onCloseTray?()
                    }
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.white.opacity(0.2) : Color.clear)
        )
        .scaleEffect(isBeingDragged ? 0.95 : 1.0)
        .opacity(isBeingDragged ? 0.7 : 1.0)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onDrag {
            isBeingDragged = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
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
