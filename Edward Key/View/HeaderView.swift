//
//  HeaderView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .blue.opacity(0.2),
                                .blue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Edward Key")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Vietnamese Input Method")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 28)
        .padding(.bottom, 24)
    }
}
