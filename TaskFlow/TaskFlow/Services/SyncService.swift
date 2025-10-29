//
//  SyncService.swift
//  TaskFlow
//
//  Basit otomatik senkron: online olunca upload+download.
//  Router/DI yok. Outbox yok. Sadece Task & Firestore.
//
import Foundation
import SwiftData
import Network   // NWPathMonitor

@MainActor
final class SyncService {
    private let context: ModelContext
    private let monitor = NWPathMonitor()
    private var isStarted = false

    init(context: ModelContext) {
        self.context = context
    }

    /// App açılışında bir kez çağır.
    func start() {
        guard !isStarted else { return }
        isStarted = true

        let queue = DispatchQueue(label: "SyncService.Monitor")
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status == .satisfied {
                Task { [weak self] in
                    guard let self else { return }
                    await self.syncNow()
                }
            }
        }
        monitor.start(queue: queue)
    }


    /// Manuel tetikleme (Ayarlar’dan).
    func syncNow() async {
        do {
            try await SyncManager.uploadAll(context: context)
            try await SyncManager.downloadAll(context: context)
        } catch {
            #if DEBUG
            print("⚠️ Sync failed:", error.localizedDescription)
            #endif
        }
    }

    deinit {
        monitor.cancel()
    }
}
