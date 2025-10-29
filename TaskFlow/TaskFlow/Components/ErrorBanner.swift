//
//  ErrorBanner.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


import SwiftUI

struct ErrorBanner: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.octagon.fill")
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(.white)
        .padding(10)
        .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
    }
}
