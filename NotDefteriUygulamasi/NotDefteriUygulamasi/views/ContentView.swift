//
//  ContentView.swift
//  NotDefteriUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = NotesViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.notes) { note in
                    NavigationLink(value: note) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title.isEmpty ? "(Başlıksız)" : note.title)
                                .font(.headline)
                            Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Not Defteri")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: { Label("Ekle", systemImage: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddNoteSheet { title, content in
                    vm.add(title: title, content: content)
                }
            }
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note)
            }
        }
    }
}

// MARK: - PREVIEW
#Preview { ContentView() }
