//
//  AddEditNoteView.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//


import SwiftUI
import CoreData

struct AddEditNoteView: View {
    enum Mode { case add, edit(Note) }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc

    let mode: Mode
    var onSave: (_ title: String, _ content: String) -> Void

    @State private var title: String = ""
    @State private var content: String = ""

    // Associated value'lu enum'da == kullanmak yerine pattern matching ile karar verelim
    private var isAdd: Bool {
        if case .add = mode { return true } else { return false }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("Başlık", text: $title)
                }
                Section("İçerik") {
                    TextField("İçerik", text: $content, axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                }
            }
            .navigationTitle(isAdd ? "Yeni Not" : "Notu Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isAdd ? "Kaydet" : "Güncelle") {
                        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !t.isEmpty || !c.isEmpty else { return }

                        switch mode {
                        case .add:
                            onSave(t, c)
                        case .edit(let note):
                            note.title = t
                            note.content = c
                            note.date = Date()
                            moc.saveIfNeeded()
                        }
                        dismiss()
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .onAppear {
                if case .edit(let n) = mode {
                    title = n.title ?? ""
                    content = n.content ?? ""
                }
            }
        }
    }
}
