//
//  FavoritesListView.swift
//  GeoFavorites
//
//  Created by Berke Özgüder on 11.10.2025.
//


import SwiftUI
import SwiftData
import MapKit

struct FavoritesListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FavoriteLocation.createdAt, order: .reverse) private var favorites: [FavoriteLocation]

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { fav in
                    NavigationLink(value: fav) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "mappin.circle.fill").imageScale(.large)
                            VStack(alignment: .leading) {
                                Text(fav.name).font(.headline)
                                if let addr = fav.address { Text(addr).font(.subheadline).foregroundStyle(.secondary).lineLimit(2) }
                                Text(String(format: "(%.5f, %.5f)", fav.latitude, fav.longitude))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { favorites[$0] }.forEach(context.delete)
                    try? context.save()
                }
            }
            .navigationTitle("Favori Konumlar")
            .toolbar { EditButton() }
            .navigationDestination(for: FavoriteLocation.self) { fav in
                FavoriteDetailView(favorite: fav)
            }
        }
    }
}

private struct FavoriteDetailView: View {
    let favorite: FavoriteLocation

    var body: some View {
        VStack(spacing: 8) {
            MapSnapshotView(center: favorite.coordinate)
                .frame(height: 260)
            VStack(alignment: .leading, spacing: 6) {
                Text(favorite.name).font(.title3).bold()
                if let addr = favorite.address { Text(addr).font(.subheadline).foregroundStyle(.secondary) }
                Text(String(format: "Lat: %.6f\nLon: %.6f", favorite.latitude, favorite.longitude)).font(.footnote)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            Spacer()
        }
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
    }
}


private struct MapSnapshotView: UIViewRepresentable {
    let center: CLLocationCoordinate2D
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    func updateUIView(_ uiView: UIImageView, context: Context) {
      
        uiView.image = nil

        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: center, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
        options.size = CGSize(width: UIScreen.main.bounds.width, height: 260)
        let snap = MKMapSnapshotter(options: options)
        snap.start { snapshot, error in
            if let error = error {
           
                print("Snapshot error: \(error)")
                return
            }
            guard let snapshot = snapshot else { return }
            let image = snapshot.image
     
            DispatchQueue.main.async {
                uiView.image = image
            }
        }
    }
}
