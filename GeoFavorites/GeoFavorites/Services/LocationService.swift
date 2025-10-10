//
//  LocationService.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject {
    enum AuthState { case unknown, denied, restricted, whenInUse, always }

    @Published var authorization: AuthState = .unknown
    @Published var lastLocation: CLLocation?
    @Published var lastAddress: String?
    @Published var errorMessage: String?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
    }

    func requestWhenInUse() { manager.requestWhenInUseAuthorization() }
    func requestAlways() { manager.requestAlwaysAuthorization() }

    func start() {
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func reverseGeocode(_ location: CLLocation, completion: ((String?) -> Void)? = nil) {
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            if let error = error { self.errorMessage = error.localizedDescription; completion?(nil); return }
            let addr = placemarks?.first?.formattedAddress
            self.lastAddress = addr
            completion?(addr)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined: authorization = .unknown
        case .denied: authorization = .denied
        case .restricted: authorization = .restricted
        case .authorizedWhenInUse: authorization = .whenInUse
        case .authorizedAlways: authorization = .always
        @unknown default: authorization = .unknown
        }
        if authorization == .whenInUse || authorization == .always { start() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        lastLocation = loc
        reverseGeocode(loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}
