//
//  CLPlaceMark+Format.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import CoreLocation

extension CLPlacemark {
    var formattedAddress: String? {
        let comp: [String?] = [name, thoroughfare, subLocality, locality, administrativeArea, postalCode, country]
        let joined = comp.compactMap { $0 }.joined(separator: ", ")
        return joined.isEmpty ? nil : joined
    }
}
