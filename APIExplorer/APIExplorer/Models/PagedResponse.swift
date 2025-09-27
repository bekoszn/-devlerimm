//
//  PagedResponse.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

struct PagedResponse<T: Codable>: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: URL?
        let prev: URL?
    }

    let info: Info
    let results: [T]
}
