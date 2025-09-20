//
//  NoteDetailView.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//


import SwiftUI
import CoreData

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss

    let objectID: NSManagedObjectID

    @State private var note: Note?
    @State private var showEdit = false

    private let longDF: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateStyle = .full
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        Group {
            if let note {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text((note.title ?? "").isEmpty ? "(Başlıksız)" : (note.title ?? ""))
                            .font(.title2).bold()
                        Text(longDF.string(from: note.date ?? Date()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Divider()
                        Text((note.content ?? "").isEmpty ? "(İçerik yok)" : (note.content ?? ""))
                            .font(.body)
                    }
                    .padding()
                }
                .navigationTitle("Not Detayı")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button { showEdit = true } label: { Label("Düzenle", systemImage: "pencil") }
                        Button(role: .destructive) { deleteNote(note) } label: { Label("Sil", systemImage: "trash") }
                    }
                }
                .sheet(isPresented: $showEdit) {
                    AddEditNoteView(mode: .edit(note)) { _, _ in }
                }
            } else {
                ProgressView().onAppear(perform: load)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        if note == nil { note = moc.object(with: objectID) as? Note }
    }

    private func deleteNote(_ note: Note) {
        moc.delete(note)
        moc.saveIfNeeded()
        dismiss()
    }
}
