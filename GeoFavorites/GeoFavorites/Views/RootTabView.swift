//
//  RootTabView.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import SwiftUI

struct RootTabView: View {
    @StateObject private var locationService = LocationService()

    var body: some View {
        TabView {
            MapKitScreen()
                .environmentObject(locationService)
                .tabItem { Label("Harita", systemImage: "map") }

            FavoritesListView()
                .tabItem { Label("Favoriler", systemImage: "star.fill") }
        }
        .onAppear {
            if locationService.authorization == .unknown {
                locationService.requestWhenInUse()
            }
        }
    }
}
