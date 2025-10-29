//
//  SignatureStore.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 28.10.2025.
//


import Foundation
import UIKit

enum SignatureStore {
    private static var baseDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("signatures", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func url(for taskID: String) -> URL {
        baseDir.appendingPathComponent("\(taskID).png")
    }

    @discardableResult
    static func save(image: UIImage, for taskID: String) throws -> URL {
        guard let data = image.pngData() else {
            throw NSError(domain: "Signature", code: -1, userInfo: [NSLocalizedDescriptionKey: "PNG dönüştürülemedi"])
        }
        let u = url(for: taskID)
        try data.write(to: u, options: .atomic)
        return u
    }

    static func image(for taskID: String) -> UIImage? {
        let u = url(for: taskID)
        guard FileManager.default.fileExists(atPath: u.path) else { return nil }
        return UIImage(contentsOfFile: u.path)
    }

    static func delete(taskID: String) {
        let u = url(for: taskID)
        try? FileManager.default.removeItem(at: u)
    }

    static func exists(taskID: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: taskID).path)
    }
}
