//
//  CardContainer.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import Foundation
import SwiftUI

struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay for depth
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.12),
                                    .white.opacity(0.03),
                                    .white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Light border highlight
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1),
                                    .white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
