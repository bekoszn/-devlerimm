//
//  Persistence.swift
//  TaskFlow
//

import Foundation
import SwiftData

enum Persistence {
    @MainActor
    static func modelContainer() throws -> ModelContainer {
        // SwiftData için uygulama destek klasörü
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory,
                              in: .userDomainMask,
                              appropriateFor: nil,
                              create: true)
        let dir = base.appendingPathComponent("TaskFlowAppp", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        let storeURL = dir.appendingPathComponent("TaskFlow_v4.store")

        // Model yapılandırması: URL belirt
        let config = ModelConfiguration(url: storeURL)

        // Container'ı model(ler) ile oluştur
        return try ModelContainer(for: WorkItem.self, configurations: config)
    }
}
