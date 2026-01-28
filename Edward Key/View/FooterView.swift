//
//  FooterView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 28/1/26.
//
import SwiftUI

struct FooterView: View {
    var body: some View {
        Text("© 2025 EdwardLTC. Built upon the original OpenKey by @tuyenvm.")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 8)
    }
}
