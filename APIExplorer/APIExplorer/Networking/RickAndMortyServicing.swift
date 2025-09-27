//
//  RickAndMortyServicing.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

protocol RickAndMortyServicing {
    func fetchCharacters(page: Int?, name: String?) async throws -> PagedResponse<RMCharacter>
}

struct RickAndMortyService: RickAndMortyServicing {
    let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    func fetchCharacters(page: Int?, name: String?) async throws -> PagedResponse<RMCharacter> {
        guard let url = APIEndpoints.characters(page: page, name: name) else { throw APIError.invalidURL }
        return try await client.get(url)
    }
}
