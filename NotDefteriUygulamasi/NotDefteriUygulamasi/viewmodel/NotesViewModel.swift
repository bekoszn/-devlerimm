//
//  NotesViewModel.swift
//  NotDefteriUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = [] {
        didSet { saveNotes() }
    }

    private let storageKey = "notes_storage"

    init() { loadNotes() }

    func add(title: String, content: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty || !trimmedContent.isEmpty else { return }
        let newNote = Note(title: trimmedTitle, content: trimmedContent)
        notes.insert(newNote, at: 0)
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ Encode error: \(error)")
        }
    }

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("❌ Decode error: \(error)")
            notes = []
        }
    }
}
