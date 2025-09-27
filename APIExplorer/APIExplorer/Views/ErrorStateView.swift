//
//  ErrorStateView.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.yellow)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}
