//
//  LoadingView.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


import SwiftUI

struct LoadingView: View {
    let text: String?
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            if let t = text { Text(t).font(.subheadline).foregroundStyle(.secondary) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
