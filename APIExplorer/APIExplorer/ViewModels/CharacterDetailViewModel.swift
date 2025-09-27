//
//  CharacterDetailViewModel.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation
import Combine

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    let character: RMCharacter

    init(character: RMCharacter) {
        self.character = character
    }
}
