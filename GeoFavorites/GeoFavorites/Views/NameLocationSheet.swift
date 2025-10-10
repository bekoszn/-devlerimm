//
//  NameLocationSheet.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import SwiftUI

struct NameLocationSheet: View {
    var defaultAddress: String
    var onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Konum Adı") { TextField("Örn. İş, Ev, Kafe…", text: $name) }
                if !defaultAddress.isEmpty { Section("Adres") { Text(defaultAddress).font(.footnote) } }
            }
            .navigationTitle("Favoriye Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Vazgeç") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { onSave(name); dismiss() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && defaultAddress.isEmpty)
                }
            }
        }
    }
}