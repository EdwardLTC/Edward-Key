//
//  FileItem.swift
//  Edward Key
//
//  Created by Thành Công Lê on 30/9/25.
//


// Models.swift
import SwiftUI

struct FileItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: String
    let url: URL
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}
