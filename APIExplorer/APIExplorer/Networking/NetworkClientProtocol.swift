//
//  NetworkClientProtocol.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

protocol NetworkClientProtocol {
    func get<T: Decodable>(_ url: URL) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        let (data, resp): (Data, URLResponse)
        do {
            (data, resp) = try await session.data(from: url)
        } catch let e as URLError {
            throw APIError.network(e)
        } catch {
            throw APIError.unknown
        }

        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }
        guard (200..<300).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
