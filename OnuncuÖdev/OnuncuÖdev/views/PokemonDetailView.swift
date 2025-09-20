//
//  PokemonDetailView.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 20.09.2025.
//
import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonListItem
    @State private var detail: PokemonDetail?
    @State private var isLoading = false
    @State private var error: String?
    private let api = PokeAPI()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: pokemon.imageURL) { phase in
                    switch phase {
                    case .empty:         ProgressView().frame(height: 220)
                    case .success(let i): i.resizable().scaledToFit().frame(height: 220)
                    case .failure:       Image(systemName: "photo").font(.largeTitle).frame(height: 220)
                    @unknown default:    EmptyView().frame(height: 220)
                    }
                }
                Text(pokemon.displayName).font(.title2).bold()
                Text("#\(pokemon.id)").font(.subheadline).foregroundStyle(.secondary)

                if let d = detail {
                    let types = d.types.map { $0.type.name.capitalized }.joined(separator: ", ")
                    HStack(spacing: 12) {
                        Label("Tipler: \(types)", systemImage: "tag")
                        Spacer()
                    }.frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 24) {
                        Label("Boy: \(d.height)", systemImage: "ruler")
                        Label("Kilo: \(d.weight)", systemImage: "scalemass")
                    }
                }

                if let error { Text(error).foregroundStyle(.red) }
            }
            .padding()
        }
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Preview’da ağa çıkma
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                detail = PokemonDetail(
                    id: pokemon.id,
                    height: 7,
                    weight: 69,
                    sprites: .init(front_default: nil),
                    types: [.init(type: .init(name: "electric"))]
                )
            } else {
                await loadDetail()
            }
        }
    }

    private func loadDetail() async {
        guard detail == nil && !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do { detail = try await api.fetchDetail(id: pokemon.id) }
        catch { self.error = error.localizedDescription }
    }
}
