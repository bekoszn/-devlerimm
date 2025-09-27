//
//  APIExplorerApp.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//

import SwiftUI
import Combine

@main
struct APIExplorerApp: App {
    @StateObject private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favorites)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            CharacterListView()
                .tabItem { Label("Characters", systemImage: "person.3.fill") }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "star.fill") }
        }
    }
}
