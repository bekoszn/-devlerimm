//
//  ContentView.swift
//  BasitSayacUygulamasiUI
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI


struct ContentView: View {
    @State private var count: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Sayaç")
                .font(.title)
                .fontWeight(.semibold)

            Text("\(count)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .accessibilityLabel("Sayaç değeri: \(count)")

            HStack(spacing: 16) {
                Button {
                    if count > 0 { count -= 1 }
                } label: {
                    Label("Azalt", systemImage: "minus")
                        .labelStyle(.titleAndIcon)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(count == 0)
                .accessibilityLabel("Azalt butonu")
                .accessibilityHint("Sayaç değerini bir azaltır. Sıfırın altına inmez.")

                Button {
                    count += 1
                } label: {
                    Label("Arttır", systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Arttır butonu")
                .accessibilityHint("Sayaç değerini bir arttırır.")
            }
        }
        .padding(24)
    }
}

#Preview {
    ContentView()
}
