//
//  ImageLoader.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import UIKit
import Combine

final class ImageLoader: ObservableObject {
static let shared = ImageLoader()

private let cache = NSCache<NSURL, UIImage>()

func image(for url: URL) async throws -> UIImage {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let img = UIImage(data: data) else {
            throw APIError.decodingFailed
        }
        cache.setObject(img, forKey: key)
        return img
    }
}
