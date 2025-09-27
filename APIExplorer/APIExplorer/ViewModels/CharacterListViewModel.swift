//
//  CharacterListViewModel.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//

import Foundation
import Combine

@MainActor
final class CharacterListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(canLoadMore: Bool)
        case empty
        case error(String)
    }

    @Published private(set) var items: [RMCharacter] = []
    @Published private(set) var state: State = .idle
    @Published var searchText: String = ""

    private let service: RickAndMortyServicing
    private var page = 1
    private var lastQuery = ""
    private var canLoadMore = true

    init(service: RickAndMortyServicing) {
        self.service = service
    }

    convenience init() {
        self.init(service: RickAndMortyService())
    }

    func refresh() async {
        page = 1
        canLoadMore = true
        await load(reset: true)
    }

    func searchChanged(to text: String) async {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized != lastQuery {
            lastQuery = normalized
            await refresh()
        }
    }

    func loadMoreIfNeeded(current item: RMCharacter?) async {
        guard let item else { return }

        // Clamp the threshold to startIndex to avoid out-of-bounds when items.count < 5
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5, limitedBy: items.startIndex) ?? items.startIndex

        if let currentIndex = items.firstIndex(where: { $0.id == item.id }),
           currentIndex >= thresholdIndex,
           canLoadMore {
            page += 1
            await load(reset: false)
        }
    }

    private func load(reset: Bool) async {
        if reset { state = .loading }
        do {
            let resp = try await service.fetchCharacters(page: page, name: lastQuery.isEmpty ? nil : lastQuery)
            if reset { items.removeAll() }
            items.append(contentsOf: resp.results)
            canLoadMore = (resp.info.next != nil)
            state = items.isEmpty ? .empty : .loaded(canLoadMore: canLoadMore)
        } catch {
            state = .error((error as? APIError)?.localizedDescription ?? error.localizedDescription)
        }
    }
}
