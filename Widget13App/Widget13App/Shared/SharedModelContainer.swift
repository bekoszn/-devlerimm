//
//  SharedModelContainer.swift
//  Widget13App
//
//  Created by Berke Özgüder on 20.10.2025.
//


import SwiftData
import Foundation
internal import UniformTypeIdentifiers

enum SharedModelContainer {
    static func make() throws -> ModelContainer {
        let schema = Schema([TaskItem.self])

        // Resolve the App Group container URL for SwiftData storage
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            throw NSError(domain: "SharedModelContainer", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "App Group container URL could not be resolved for id: \(AppConstants.appGroupID)"
            ])
        }

        let config = ModelConfiguration(
            "Shared",
            url: groupURL.appendingPathComponent("SwiftData.store", conformingTo: .database)
        )

        return try ModelContainer(for: schema, configurations: [config])
    }
}
