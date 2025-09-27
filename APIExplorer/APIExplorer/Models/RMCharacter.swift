//
//  RMCharacter.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

struct RMCharacter: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationRef
    let location: LocationRef
    let image: URL
    let episode: [URL]
    let url: URL
    let created: Date

    struct LocationRef: Codable, Hashable {
        let name: String
        let url: String?
    }
}
