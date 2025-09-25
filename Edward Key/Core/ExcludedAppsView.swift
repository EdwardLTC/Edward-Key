//
//  ExcludedAppsView.swift
//  Edward Key
//
//  Created by Thành Công Lê on 25/9/25.
//

import SwiftUI

struct ExcludedAppsView: View {
    @EnvironmentObject var model: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Excluded Apps")
                .font(.title3)
                .bold()
            
            if model.excludedApps.isEmpty {
                Text("No excluded apps yet.")
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            } else {
                List {
                    ForEach(model.excludedApps, id: \.self) { bundleID in
                        HStack {
                            Text(bundleID)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(action: {
                                model.excludedApps.removeAll { $0 == bundleID }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                }
                .listStyle(.plain)
            }
            
            Spacer()
        }
        .frame(minWidth: 300, minHeight: 0)
        .fixedSize(horizontal: false, vertical: true)
        .padding(25)
    }
}
