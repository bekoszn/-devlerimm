//
//  EmptyStateView.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//

import SwiftUI

// MARK: - Ek küçük yardımcı (EmptyStateView sizde zaten varsa kendi versiyonunuz kullanılacak)


struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .imageScale(.large)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.bottom, 4)
            Text(title).font(.headline).foregroundStyle(.white)
            Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }
}
