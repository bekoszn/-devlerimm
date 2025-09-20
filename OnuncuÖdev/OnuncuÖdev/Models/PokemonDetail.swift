//
//  PokemonDetail.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 18.09.2025.
//
import Foundation

struct PokemonDetail: Codable {
    struct SpriteContainer: Codable { let front_default: String? }
    struct TypeEntry: Codable { struct TypeName: Codable { let name: String }; let type: TypeName }
    let id: Int
    let height: Int
    let weight: Int
    let sprites: SpriteContainer
    let types: [TypeEntry]
}

