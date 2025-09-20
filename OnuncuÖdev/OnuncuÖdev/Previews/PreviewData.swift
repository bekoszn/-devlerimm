//
//  PreviewData.swift
//  OnuncuÖdev
//
//  Created by Berke Özgüder on 18.09.2025.
//

import SwiftUI

#Preview("Liste") {
    PokedexListView()
}

#Preview("Detay") {
    NavigationStack {
        PokemonDetailView(
            pokemon: PokemonListItem(
                name: "pikachu",
                url: "https://pokeapi.co/api/v2/pokemon/25/"
            )
        )
    }
}
