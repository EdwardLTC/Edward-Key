//
//  FloatingTrayView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers
import QuickLookThumbnailing

struct FloatingTrayView: View {
    @ObservedObject var trayManager: TrayManager
    @State private var isDropTargeted = false
    @State private var isHovered = false
    @State private var hoveredFileId: UUID?
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Header
            VStack(spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    // Icon with gradient background
                    Image(systemName: "tray.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("File Tray")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("\(trayManager.files.count) file\(trayManager.files.count != 1 ? "s" : "")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if !trayManager.files.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    trayManager.clearTray()
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onCloseTray?()
                                }
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Clear All")
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                onCloseTray?()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Close Tray")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            
            Divider()
                .background(Color.primary.opacity(0.08))
            
            // Content Area
            if trayManager.files.isEmpty {
                EmptyTrayView(isTargeted: isDropTargeted)
                    .frame(maxHeight: .infinity)
            } else {
                FilesListView(trayManager: trayManager, hoveredFileId: $hoveredFileId, onCloseTray: onCloseTray)
            }
        }
        .frame(width: 360, height: 520)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isDropTargeted ?
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [.white.opacity(0.2), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isDropTargeted ? 2 : 1
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
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
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isTargeted ? Color.blue.opacity(0.15) : Color.gray.opacity(0.08),
                                    isTargeted ? Color.cyan.opacity(0.08) : Color.gray.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isTargeted ? 1.1 : 1.0)
                    
                    Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "tray")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(
                            isTargeted ?
                            LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [.secondary.opacity(0.5), .secondary.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                        )
                        .symbolEffect(.bounce, value: isTargeted)
                }
                .frame(height: 100)
                
                VStack(spacing: 8) {
                    Text(isTargeted ? "Drop Files Here" : "Your Tray is Empty")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(isTargeted ? 
                        "Release to add files to your tray" : 
                        "Drag files to the right edge of screen\nto open this tray")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? Color.blue.opacity(0.06) : Color.clear)
                .padding(16)
        )
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTargeted)
    }
}

struct FilesListView: View {
    @ObservedObject var trayManager: TrayManager
    @Binding var hoveredFileId: UUID?
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 8) {
                ForEach(trayManager.files) { file in
                    TrayFileItemView(
                        file: file,
                        trayManager: trayManager,
                        isHovered: hoveredFileId == file.id,
                        onHoverChanged: { isHovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                hoveredFileId = isHovering ? file.id : nil
                            }
                        },
                        onCloseTray: onCloseTray
                    )
                }
            }
            .padding(12)
        }
        .scrollIndicators(.visible)
    }
}

struct TrayFileItemView: View {
    let file: FileItem
    @ObservedObject var trayManager: TrayManager
    @State private var isBeingDragged = false
    @State private var thumbnailImage: NSImage?
    let isHovered: Bool
    let onHoverChanged: (Bool) -> Void
    var onCloseTray: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // File Icon with background
            VStack {
                if let thumbnail = thumbnailImage {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipped()
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                        )
                } else {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                }
            }
            .frame(width: 44, height: 44)
            .cornerRadius(5)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .onAppear {
                loadThumbnail()
            }
            
            // File Info
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Text(file.type.isEmpty ? "File" : file.type.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer(minLength: 0)
                    
                    if let fileSize = getFileSizeString(file.url) {
                        Text(fileSize)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 4) {
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([file.url])
                }) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(isHovered ? 0.15 : 0.08))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Show in Finder")
                
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        trayManager.removeFromTray(file)
                    }
                    
                    if trayManager.files.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onCloseTray?()
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(isHovered ? 0.15 : 0.08))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Remove from tray")
            }
            .opacity(isHovered ? 1 : 0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? Color.blue.opacity(0.08) : Color.gray.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovered ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isBeingDragged ? 0.96 : 1.0)
        .opacity(isBeingDragged ? 0.5 : 1.0)
        .onHover { hovering in
            onHoverChanged(hovering)
        }
        .onDrag {
            isBeingDragged = true
            
            // Start drag animation
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                // Visual feedback handled by isBeingDragged state
            }
            
            // Remove file after drag starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    trayManager.removeFromTray(file)
                }
                
                // Close tray after removal animation completes if empty
                if trayManager.files.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onCloseTray?()
                    }
                }
            }
            
            return NSItemProvider(object: file.url as NSURL)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isBeingDragged)
    }
    
    private func getFileSizeString(_ url: URL) -> String? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? Int else {
            return nil
        }
        
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(fileSize))
    }
    
    private func loadThumbnail() {
        let size = CGSize(width: 64, height: 64)
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        
        let request = QLThumbnailGenerator.Request(
            fileAt: file.url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )
        
        QLThumbnailGenerator.shared.generateRepresentations(for: request) { thumbnail, type, error in
            DispatchQueue.main.async {
                if let thumbnail = thumbnail {
                    self.thumbnailImage = thumbnail.nsImage
                }
            }
        }
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

