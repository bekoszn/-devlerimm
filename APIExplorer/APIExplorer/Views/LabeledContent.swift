//
//  LabeledContent.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//

import SwiftUI
import Combine

struct CharacterDetailView: View {
    @ObservedObject var vm: CharacterDetailViewModel
    @EnvironmentObject var favorites: FavoritesStore
    @State private var hero: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                info
            }
            .padding()
        }
        .navigationTitle(vm.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadHero() }
    }

    private var header: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if let hero {
                    Image(uiImage: hero)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button(action: { favorites.toggle(vm.character.id) }) {
                Image(systemName: favorites.isFavorite(vm.character.id) ? "star.circle.fill" : "star.circle")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(12)
        }
    }

    private var info: some View {
        VStack(spacing: 8) {
            LabeledContent("Status", value: vm.character.status)
            LabeledContent("Species", value: vm.character.species)
            if !vm.character.type.isEmpty { LabeledContent("Type", value: vm.character.type) }
            LabeledContent("Gender", value: vm.character.gender)
            LabeledContent("Origin", value: vm.character.origin.name)
            LabeledContent("Location", value: vm.character.location.name)
            LabeledContent("Episodes", value: "\(vm.character.episode.count)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func loadHero() async {
        do {
            hero = try await ImageLoader.shared.image(for: vm.character.image)
        } catch {
            // ignore errors; keep spinner if image fails
        }
    }
}
