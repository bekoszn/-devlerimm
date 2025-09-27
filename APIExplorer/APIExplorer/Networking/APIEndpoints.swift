//
//  APIEndpoints.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

enum APIEndpoints {
static let base = URL(string: "https://rickandmortyapi.com/api")!

static func characters(page: Int?, name: String?) -> URL? {
        var comps = URLComponents(url: base.appending(path: "/character"), resolvingAgainstBaseURL: false)
        var q: [URLQueryItem] = []
        if let page { q.append(.init(name: "page", value: String(page))) }
        if let name, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            q.append(.init(name: "name", value: name))
        }
        comps?.queryItems = q.isEmpty ? nil : q
        return comps?.url
    }
}