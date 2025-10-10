//
//  FavoriteLocation.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import Foundation
import SwiftData
import CoreLocation

@Model
final class FavoriteLocation: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var address: String?
    var createdAt: Date

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, address: String? = nil, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
}