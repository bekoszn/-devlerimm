//
//  CleanupService.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 29.10.2025.
//


import Foundation
import SwiftData

@MainActor
struct CleanupService {
    private let repo: TaskRepositoryProtocol = FirebaseTaskRepository()

    /// Firestore'da olmayan veya tombstone olan kayıtları **lokal SwiftData'dan** siler.
    func purgeLocalsNotInRemote(context: ModelContext) async {
        do {
            let index = try await repo.listRemoteIndex()

            var fd = FetchDescriptor<WorkItem>()
            let locals = try context.fetch(fd)

            var removed = 0
            for item in locals {
                let id = item.id

                // 1) Lokal zaten tombstone ise: doğrudan lokali kaldır
                // 2) Remote'ta 'deletedIDs' içindeyse: lokali kaldır
                // 3) Remote aktif setinde YOKSA: lokali kaldır (yetim)
                let shouldRemove =
                    item.isDeleted ||
                    index.deletedIDs.contains(id) ||
                    !index.activeIDs.contains(id)

                if shouldRemove {
                    context.delete(item)
                    removed += 1
                }
            }
            try context.save()
            print("CleanupService: removed=\(removed) local orphans/tombstones")
        } catch {
            print("CleanupService error:", error.localizedDescription)
        }
    }
}
