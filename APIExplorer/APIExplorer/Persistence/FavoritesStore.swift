//
//  FavoritesStore.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var ids: Set<Int> = []
    private let key = "favorites.character.ids"

    init() { load() }

    func toggle(_ id: Int) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        save()
    }

    func isFavorite(_ id: Int) -> Bool { ids.contains(id) }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            ids = saved
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
