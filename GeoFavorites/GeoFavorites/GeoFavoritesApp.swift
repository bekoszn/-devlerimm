//
//  GeoFavoritesApp.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 10.10.2025.
//
import SwiftUI
import SwiftData

@main
struct GeoFavoritesApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: FavoriteLocation.self)
    }
}
