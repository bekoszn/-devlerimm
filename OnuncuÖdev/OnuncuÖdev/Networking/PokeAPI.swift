//
//  PokeAPI.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//

import Foundation

struct PokeAPI: PokeAPIProtocol {
    func fetchList(limit: Int = 151) async throws -> [PokemonListItem] {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)") else { throw URLError(.badURL) }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PokemonListResponse.self, from: data).results
    }

    func fetchDetail(id: Int) async throws -> PokemonDetail {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)") else { throw URLError(.badURL) }
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(PokemonDetail.self, from: data)
    }
}
