//
//  MapKitScreen.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import SwiftUI
import MapKit
import SwiftData
import CoreLocation

private struct CoordinateKey: Equatable {
    let lat: Double
    let lon: Double
}

struct MapKitScreen: View {
    @EnvironmentObject private var locationService: LocationService
    @Environment(\.modelContext) private var modelContext

    @State private var centerOnUser: CLLocationCoordinate2D? = nil
    @State private var tappedCoordinate: CLLocationCoordinate2D? = nil
    @State private var showingNameSheet = false
    @State private var tempAddress: String? = nil


    private var tappedKey: CoordinateKey? {
        if let c = tappedCoordinate { return CoordinateKey(lat: c.latitude, lon: c.longitude) }
        return nil
    }

    var body: some View {
        VStack(spacing: 8) {
            header
            MapKitMapView(centerOnUser: $centerOnUser, tappedCoordinate: $tappedCoordinate)
                .frame(maxHeight: .infinity)
                .onChange(of: tappedKey) { _, _ in
                    guard let coord = tappedCoordinate else { return }
                    // Reverse-geocode tapped point for default name/address
                    let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    locationService.reverseGeocode(loc) { addr in
                        tempAddress = addr
                        showingNameSheet = true
                    }
                }
            infoBar
        }
        .sheet(isPresented: $showingNameSheet) {
            NameLocationSheet(defaultAddress: tempAddress ?? "") { name in
                if let coord = tappedCoordinate {
                    let fav = FavoriteLocation(
                        name: name.isEmpty ? (tempAddress ?? "Favori Konum") : name,
                        latitude: coord.latitude,
                        longitude: coord.longitude,
                        address: tempAddress
                    )
                    modelContext.insert(fav)
                    try? modelContext.save()
                }
                tappedCoordinate = nil
            }
            .presentationDetents([.medium])
        }
        .onReceive(locationService.$lastLocation) { loc in
            guard let loc else { return }
            centerOnUser = loc.coordinate
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Anlık Konum").font(.headline)
                Text(locationService.lastAddress ?? "İzin bekleniyor…")
                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Menu {
                Button("When In Use izni iste") { locationService.requestWhenInUse() }
                Button("Always izni iste") { locationService.requestAlways() }
            } label: {
                Image(systemName: "location.circle").imageScale(.large)
            }
        }
        .padding(.horizontal)
    }

    private var infoBar: some View {
        VStack(spacing: 6) {
            if let loc = locationService.lastLocation {
                HStack(spacing: 12) {
                    Label("Lat: \(String(format: "%.5f", loc.coordinate.latitude))", systemImage: "globe")
                    Label("Lon: \(String(format: "%.5f", loc.coordinate.longitude))", systemImage: "location.north")
                }
                .font(.footnote)
            }
            Text((locationService.lastAddress ?? "Adres bulunamadı"))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
