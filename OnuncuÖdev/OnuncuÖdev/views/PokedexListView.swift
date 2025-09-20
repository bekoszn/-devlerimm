//
//  PokedexListView.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//

import SwiftUI

struct PokedexListView: View {
    @StateObject private var vm = PokedexViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Pokédex")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: refresh) { Image(systemName: "arrow.clockwise") }
                            .accessibilityLabel("Yenile")
                    }
                }
        }
        .task {
            if case .idle = vm.state {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    #if DEBUG
                    vm.loadMock()     // Preview: mock veri
                    #endif
                } else {
                    await vm.load()   // Gerçek çalışma: ağ
                }
            }
        }
        .searchable(text: $vm.searchText, prompt: "Ara (örn: Pikachu)")
        .refreshable { await vm.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Yükleniyor…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                Text("Bir hata oluştu")
                Text(message).font(.footnote).foregroundStyle(.secondary)
                Button("Tekrar Dene", action: refresh)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        case .loaded:
            List(vm.filtered, id: \.self) { pokemon in
                NavigationLink(value: pokemon) {
                    PokemonRow(pokemon: pokemon)
                }
            }
            .navigationDestination(for: PokemonListItem.self) { pokemon in
                PokemonDetailView(pokemon: pokemon)
            }
        }
    }

    private func refresh() { Task { await vm.load() } }
}

fileprivate struct PokemonRow: View {
    let pokemon: PokemonListItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: pokemon.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(width: 56, height: 56)
                case .success(let img):
                    img.resizable().scaledToFit().frame(width: 56, height: 56)
                case .failure:
                    Image(systemName: "photo").frame(width: 56, height: 56)
                @unknown default:
                    EmptyView().frame(width: 56, height: 56)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.displayName).font(.headline)
                Text("#\(pokemon.id)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}
