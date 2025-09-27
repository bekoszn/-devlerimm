//
//  APIParsingTests.swift
//  APIExplorerTests
//
//  Created by Berke Özgüder on 27.09.2025.
//

import XCTest
@testable import APIExplorer

final class APIParsingTests: XCTestCase {
    @MainActor
    func testDecodeCharacters() throws {
        let json = """
        {"info":{"count":1,"pages":1,"next":null,"prev":null},"results":[{"id":1,"name":"Rick Sanchez","status":"Alive","species":"Human","type":"","gender":"Male","origin":{"name":"Earth","url":"https://rickandmortyapi.com/api/location/1"},"location":{"name":"Citadel of Ricks","url":"https://rickandmortyapi.com/api/location/3"},"image":"https://rickandmortyapi.com/api/character/avatar/1.jpeg","episode":["https://rickandmortyapi.com/api/episode/1"],"url":"https://rickandmortyapi.com/api/character/1","created":"2017-11-04T18:48:46.250Z"}]}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let page = try decoder.decode(PagedResponse<RMCharacter>.self, from: json)
        XCTAssertEqual(page.results.first?.name, "Rick Sanchez")
        XCTAssertEqual(page.results.first?.id, 1)
    }
}

