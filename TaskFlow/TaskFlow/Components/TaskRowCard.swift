//
//  TaskRowCard.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//
import SwiftUI

struct TaskRowCard<Content: View>: View {
    let corner: CGFloat
    var tint: Color
    let content: () -> Content

    init(corner: CGFloat, tint: Color = .blue, @ViewBuilder content: @escaping () -> Content) {
        self.corner = corner
        self.tint = tint
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(tint.opacity(0.4), lineWidth: 1)
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
