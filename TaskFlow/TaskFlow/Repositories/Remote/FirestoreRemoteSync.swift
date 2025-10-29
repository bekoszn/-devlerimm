//
//  FirestoreRemoteSync.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 29.10.2025.
//


import Foundation
import FirebaseFirestore
import SwiftData

/// Firestore → SwiftData tek yön realtime senkron.
/// UI’ı haberdar etmek için Notification yayınlar.
final class FirestoreRemoteSync {
    static let didApplyNotification = Notification.Name("FirestoreRemoteSyncDidApply")

    private let db = Firestore.firestore()
    private var col: CollectionReference { db.collection(WorkItemDTO.collection) }
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    func start(context: ModelContext) {
        // isDeleted==false filtreli, updatedAt’a göre sıralı snapshot
        listener = col
            .order(by: "updatedAt", descending: false)
            .addSnapshotListener { [weak self] snap, error in
                guard let self else { return }
                if let error { print("RemoteSync error:", error); return }
                guard let snap else { return }

                context.persist {
                    for change in snap.documentChanges {
                        do {
                            let dto = try change.document.data(as: WorkItemDTO.self)

                            // Mevcut var mı?
                            let pred = #Predicate<WorkItem> { $0.id == dto.id }
                            var fd = FetchDescriptor<WorkItem>(predicate: pred)
                            fd.fetchLimit = 1
                            let existing = try? context.fetch(fd).first

                            let up = dto.apply(to: existing)

                            if dto.isDeleted {
                                // Soft delete → localde de işaretle ve UI’dan sakla
                                up.isDeleted = true
                            }

                            context.insert(up) // existing ise replace etmeyecek, referans aynı
                        } catch {
                            print("Decode/apply error:", error)
                        }
                    }

                    do { try context.save() } catch { print("SwiftData save error:", error) }
                }

                NotificationCenter.default.post(name: FirestoreRemoteSync.didApplyNotification, object: nil)
            }
    }
}

private extension ModelContext {
    /// SwiftData transaction helper
    func persist(_ block: () -> Void) {
        block()
    }
}
