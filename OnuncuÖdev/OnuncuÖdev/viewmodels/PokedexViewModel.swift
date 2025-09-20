//
//  PokedexViewModel.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//

import Foundation

@MainActor
final class PokedexViewModel: ObservableObject {
    enum State { case idle, loading, loaded([PokemonListItem]), failed(String) }

    @Published private(set) var state: State = .idle
    @Published var searchText: String = ""

    private let api: PokeAPIProtocol
    init(api: PokeAPIProtocol = PokeAPI()) { self.api = api }

    func load(limit: Int = 151) async {
        state = .loading
        do {
            let items = try await api.fetchList(limit: limit)
            state = .loaded(items)
        } catch let e as URLError {
            state = .failed(e.localizedDescription)
        } catch {
            state = .failed("Beklenmeyen bir hata oluştu.")
        }
    }

    var filtered: [PokemonListItem] {
        guard case .loaded(let items) = state else { return [] }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.displayName.localizedCaseInsensitiveContains(q) }
    }
}

#if DEBUG
extension PokedexViewModel {
    /// Preview'da ağa çıkmamak için örnek veri
    func loadMock() {
        state = .loaded([
            .init(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            .init(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/"),
            .init(name: "squirtle",   url: "https://pokeapi.co/api/v2/pokemon/7/")
        ])
    }
}
#endif
