//
//  AddNoteSheet.swift
//  NotDefteriUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct AddNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""

    var onAdd: (_ title: String, _ content: String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("Başlık", text: $title)
                }
                Section("İçerik") {
                    TextField("İçerik", text: $content, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                }
            }
            .navigationTitle("Yeni Not")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        onAdd(title, content)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview { AddNoteSheet(onAdd: { _, _ in }) }
