//
//  PokeAPIProtocol.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//

import Foundation

protocol PokeAPIProtocol {
    func fetchList(limit: Int) async throws -> [PokemonListItem]
    func fetchDetail(id: Int) async throws -> PokemonDetail
}
