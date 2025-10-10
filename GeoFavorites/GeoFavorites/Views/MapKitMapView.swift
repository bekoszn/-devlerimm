//
//  MapKitMapView.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct MapKitMapView: UIViewRepresentable {
    @Environment(\.modelContext) private var context
    @Query(sort: \FavoriteLocation.createdAt, order: .reverse) private var favorites: [FavoriteLocation]

    @Binding var centerOnUser: CLLocationCoordinate2D?
    @Binding var tappedCoordinate: CLLocationCoordinate2D?

    func makeUIView(context ctx: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = ctx.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.pointOfInterestFilter = .includingAll
        map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")

       
        let tap = UITapGestureRecognizer(target: ctx.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        map.addGestureRecognizer(tap)
        return map
    }

    func updateUIView(_ uiView: MKMapView, context ctx: Context) {
     
        if let coord = centerOnUser {
            let region = MKCoordinateRegion(center: coord, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
            uiView.setRegion(region, animated: true)
            DispatchQueue.main.async { self.centerOnUser = nil }
        }

     
        let existing = uiView.annotations.compactMap { $0 as? MKPointAnnotation }
        uiView.removeAnnotations(existing)
        for fav in favorites {
            let ann = MKPointAnnotation()
            ann.title = fav.name
            ann.subtitle = fav.address
            ann.coordinate = fav.coordinate
            uiView.addAnnotation(ann)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapKitMapView
        init(_ parent: MapKitMapView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let map = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: map)
            let coord = map.convert(point, toCoordinateFrom: map)
            parent.tappedCoordinate = coord
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation) as! MKMarkerAnnotationView
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.displayPriority = .required
            return view
        }
    }
}
