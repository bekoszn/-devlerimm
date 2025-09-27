//
//  CharacterListViewModelTests.swift
//  APIExplorerTests
//
//  Created by Berke Özgüder on 27.09.2025.
//

import XCTest
@testable import APIExplorer

@MainActor
final class CharacterListViewModelTests: XCTestCase {

    struct MockService: RickAndMortyServicing {
        let pages: [[RMCharacter]]

        func fetchCharacters(page: Int?, name: String?) async throws -> PagedResponse<RMCharacter> {
            let idx = max(0, (page ?? 1) - 1)
            let results = idx < pages.count ? pages[idx] : []
            let info = PagedResponse<RMCharacter>.Info(
                count: pages.flatMap { $0 }.count,
                pages: pages.count,
                next: idx + 1 < pages.count ? URL(string: "https://next") : nil,
                prev: nil
            )
            return .init(info: info, results: results)
        }
    }

    func testInitialLoadAndPagination() async throws {
        let rick = RMCharacter(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: .init(name: "Earth", url: nil),
            location: .init(name: "Citadel", url: nil),
            image: URL(string: "https://example.com/a.jpg")!,
            episode: [],
            url: URL(string: "https://example.com")!,
            created: Date()
        )
        let morty = RMCharacter(
            id: 2,
            name: "Morty",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: .init(name: "Earth", url: nil),
            location: .init(name: "Citadel", url: nil),
            image: URL(string: "https://example.com/b.jpg")!,
            episode: [],
            url: URL(string: "https://example.com")!,
            created: Date()
        )

        let vm = CharacterListViewModel(service: MockService(pages: [[rick], [morty]]))

        await vm.refresh()
        XCTAssertEqual(vm.items.count, 1)

        await vm.loadMoreIfNeeded(current: vm.items.last)
        await Task.yield() // veya küçük bir sleep

        XCTAssertEqual(vm.items.count, 2)
    }

    func testSearchResetsList() async throws {
        let r1 = RMCharacter(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: .init(name: "Earth", url: nil),
            location: .init(name: "Citadel", url: nil),
            image: URL(string: "https://example.com/a.jpg")!,
            episode: [],
            url: URL(string: "https://example.com")!,
            created: Date()
        )

        let vm = CharacterListViewModel(service: MockService(pages: [[r1]]))

        await vm.refresh()
        XCTAssertEqual(vm.items.count, 1)

        await vm.searchChanged(to: "morty")
        await Task.yield()

        XCTAssertEqual(vm.items.count, 1)
    }
}
