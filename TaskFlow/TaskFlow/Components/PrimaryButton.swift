//
//  PrimaryButton.swift
//  TaskFlow
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            }
            Text(title)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.85)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .opacity(isLoading ? 0.9 : 1.0)
    }
}
