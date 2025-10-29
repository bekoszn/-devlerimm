//
//  PillTag.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


import SwiftUI

struct PillTag: View {
    let text: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let s = systemImage { Image(systemName: s) }
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
