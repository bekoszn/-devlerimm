//
//  ContentView.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//



// =============================================================
// CoreData/Persistence.swift
// Açıklama: NSPersistentContainer set-up. Eğer bundle'da "NotesModel.momd"
// bulunamazsa, aynı şemayı programatik olarak oluşturup çalıştırır (fallback).
// =============================================================



// =============================================================

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc

    @State private var sortNewestFirst: Bool = true
    @State private var searchText: String = ""
    @State private var showAdd = false

    @FetchRequest private var notes: FetchedResults<Note>

    init() {
        let sort = [NSSortDescriptor(keyPath: \Note.date, ascending: false)]
        _notes = FetchRequest(entity: Note.entity(), sortDescriptors: sort, predicate: nil, animation: .default)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAndSorted(notes), id: \.objectID) { note in
                    NavigationLink(value: note.objectID) {
                        NoteRow(note: note)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Notlar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { sortNewestFirst.toggle() } label: {
                        Label(sortNewestFirst ? "Yeni→Eski" : "Eski→Yeni", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Label("Ekle", systemImage: "plus.circle.fill") }
                }
            }
            .searchable(text: $searchText, prompt: "Başlığa göre ara")
            .sheet(isPresented: $showAdd) {
                AddEditNoteView(mode: .add) { title, content in
                    let n = Note(context: moc)
                    n.id = UUID()
                    n.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    n.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    n.date = Date()
                    moc.saveIfNeeded()
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                NoteDetailView(objectID: objectID)
            }
        }
    }

    private func filteredAndSorted(_ results: FetchedResults<Note>) -> [Note] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [Note]
        if keyword.isEmpty {
            base = Array(results)
        } else {
            base = results.filter { ($0.title ?? "").localizedCaseInsensitiveContains(keyword) }
        }
        return base.sorted { a, b in
            let da = a.date ?? .distantPast
            let db = b.date ?? .distantPast
            return sortNewestFirst ? (da > db) : (da < db)
        }
    }

    private func delete(at offsets: IndexSet) {
        let current = filteredAndSorted(notes)
        for index in offsets { moc.delete(current[index]) }
        moc.saveIfNeeded()
    }
}

fileprivate struct NoteRow: View {
    let note: Note
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text((note.title ?? "").isEmpty ? "(Başlıksız)" : (note.title ?? ""))
                .font(.headline)
            Text((note.date ?? Date()).formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}


// =============================================================
// Previews/PreviewData.swift
// Açıklama: In-memory Core Data ile çalışan önizlemeler.
// =============================================================
