//
//  NoteDetailView.swift
//  NotDefteriUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct NoteDetailView: View {
    let note: Note

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.title.isEmpty ? "(Başlıksız)" : note.title)
                    .font(.title2).bold()
                Text(note.date.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Divider()
                Text(note.content.isEmpty ? "(İçerik yok)" : note.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Not Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NoteDetailView(
        note: Note(
            id: UUID(),
            title: "Örnek Başlık",
            content: "Bu bir önizleme içeriğidir.",
            date: .now
        )
    )
}
