//
//  CharacterRowView.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import SwiftUI

struct CharacterRowView: View {
let character: RMCharacter
@EnvironmentObject var favorites: FavoritesStore
@State private var uiImage: UIImage? = nil

var body: some View {
HStack(spacing: 12) {
thumbnail
VStack(alignment: .leading, spacing: 4) {
HStack {
Text(character.name)
.font(.headline)
.lineLimit(1)
Spacer()
Button(action: { favorites.toggle(character.id) }) {
Image(systemName: favorites.isFavorite(character.id) ? "star.fill" : "star")
.foregroundStyle(.yellow)
.accessibilityLabel(favorites.isFavorite(character.id) ? "Remove favorite" : "Add favorite")
}.buttonStyle(.plain)
}
Text("\(character.species) • \(character.status)")
.font(.subheadline)
.foregroundStyle(.secondary)
.lineLimit(1)
Text("Last seen: \(character.location.name)")
.font(.caption)
.foregroundStyle(.secondary)
.lineLimit(1)
}
}
.task {
await loadImage()
}
}

private var thumbnail: some View {
ZStack {
if let uiImage { Image(uiImage: uiImage).resizable().scaledToFill() }
else { ProgressView() }
}
.frame(width: 64, height: 64)
.background(Color.gray.opacity(0.1))
.clipShape(RoundedRectangle(cornerRadius: 12))
.overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.1)))
}

private func loadImage() async {
        do {
            self.uiImage = try await ImageLoader.shared.image(for: character.image)
        } catch {
            print("image loading failed")
        }
    }
}
