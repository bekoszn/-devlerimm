//
//  CharacterListView.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import SwiftUI
import Combine

struct CharacterListView: View {
    @StateObject private var vm = CharacterListViewModel()
    @EnvironmentObject var favorites: FavoritesStore

    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .idle, .loading:
                    ProgressView().controlSize(.large)
                case .empty:
                    EmptyStateView(title: "No Results", subtitle: "Try a different name.")
                case .error(let msg):
                    ErrorStateView(message: msg) {
                        Task { await vm.refresh() }
                    }
                case .loaded:
                    list
                }
            }
            .navigationTitle("Characters")
        }
        .task { await vm.refresh() }
        .refreshable { await vm.refresh() }
        .searchable(
            text: $vm.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search by name"
        )
        .onChange(of: vm.searchText) { _, newValue in
            Task { await vm.searchChanged(to: newValue) }
        }
    }

    private var list: some View {
        List(vm.items) { item in
            NavigationLink(value: item) {
                CharacterRowView(character: item)
            }
            .task { await vm.loadMoreIfNeeded(current: item) }
        }
        .listStyle(.plain)
        .navigationDestination(for: RMCharacter.self) { character in
            CharacterDetailView(vm: .init(character: character))
        }
    }
}
