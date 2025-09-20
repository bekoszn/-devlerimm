//
//  PokemonListItem.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//
import Foundation

struct PokemonListItem: Codable, Identifiable, Hashable {
    let name: String
    let url: String

    // Güvenli id çıkarımı (Substring -> String)
    var id: Int {
        Int(url.split(separator: "/")
            .last(where: { !$0.isEmpty })
            .map(String.init) ?? "0") ?? 0
    }

    var displayName: String { name.capitalized }

    var imageURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}
