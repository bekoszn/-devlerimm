//
//  FavoritesView.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favorites: FavoritesStore
    @StateObject private var vm = CharacterListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if favorites.ids.isEmpty {
                    EmptyStateView(title: "No Favorites", subtitle: "Tap the star on any character to add here.")
                } else {
                    List(filteredItems) { item in
                        NavigationLink(destination: CharacterDetailView(vm: .init(character: item))) {
                            CharacterRowView(character: item)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
    }

    private var filteredItems: [RMCharacter] {
        vm.items.filter { favorites.ids.contains($0.id) }
    }
}
