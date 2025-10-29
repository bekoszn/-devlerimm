//
//  SyncManager.swift
//  TaskFlow
//
//  Firestore ↔ SwiftData senkronizasyonu (assigneeName tabanlı görünürlük)
//

import Foundation
import SwiftData
import FirebaseAuth
import FirebaseFirestore

enum SyncManager {
    private static var db: Firestore { Firestore.firestore() }
    private static var collection: CollectionReference { db.collection(WorkItemDTO.collection) }

    // Admin e-postaları
    private static let ADMIN_EMAILS: Set<String> = [
        "brkzgdr@gmail.com",
    ]

    private static var isAdmin: Bool {
        guard let email = Auth.auth().currentUser?.email?.lowercased() else { return false }
        return ADMIN_EMAILS.contains(email)
    }

    private static var workerDisplayName: String? {
        if let d = Auth.auth().currentUser?.displayName, !d.trimmingCharacters(in: .whitespaces).isEmpty {
            return d
        }
        if let mail = Auth.auth().currentUser?.email,
           let beforeAt = mail.split(separator: "@").first {
            return String(beforeAt)
        }
        return nil
    }

    // MARK: - UPLOAD (Local → Cloud)
    /// Tüm local WorkItem’ları Firestore’a yazar (merge, server timestamp ile).
    static func uploadAll(context: ModelContext) async throws {
        let d = FetchDescriptor<WorkItem>()
        let items = try context.fetch(d)

        try await withThrowingTaskGroup(of: Void.self) { group in
            for t in items {
                group.addTask {
                    var data: [String: Any] = [
                        "id": t.id,
                        "title": t.title,
                        "detail": t.detail,
                        "status": t.status.rawValue,
                        "assigneeName": t.assigneeName as Any,
                        "locationName": t.locationName as Any,
                        "deadline": t.deadline.map(Timestamp.init(date:)) as Any,
                        "isDeleted": t.isDeleted,
                        "signatureName": t.signatureName as Any,
                        "signatureAt": t.signatureAt.map(Timestamp.init(date:)) as Any
                    ]

                    // createdAt mevcutsa koru, yoksa server ts; updatedAt daima server ts
                    let docRef = collection.document(t.id)
                    let docSnap = try await docRef.getDocument()
                    if let ts = (docSnap.get("createdAt") as? Timestamp) {
                        data["createdAt"] = ts
                    } else {
                        data["createdAt"] = FieldValue.serverTimestamp()
                    }
                    data["updatedAt"] = FieldValue.serverTimestamp()

                    try await docRef.setData(data, merge: true)
                }
            }
            try await group.waitForAll()
        }
    }

    // MARK: - DOWNLOAD (Cloud → Local)
    /// Firestore’daki WorkItem’ları indirip SwiftData’ya merge eder.
    /// Admin: tüm aktif kayıtlar; İşçi: assigneeName == displayName
    static func downloadAll(context: ModelContext) async throws {
        let q: Query
        if isAdmin {
            q = collection
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "updatedAt", descending: false)
            let snap = try await q.getDocuments()
            try await mergeDocuments(snap.documents, context: context)
        } else if let me = workerDisplayName, !me.isEmpty {
            // assigneeName tam eşleşmeli (case-sensitive); localde lowercasing ile normalize edeceğiz
            q = collection
                .whereField("isDeleted", isEqualTo: false)
                .whereField("assigneeName", isEqualTo: me)
                .order(by: "updatedAt", descending: false)

            let snap = try await q.getDocuments()
            try await mergeDocuments(snap.documents, context: context)
        } else {
            // kimlik/isim yoksa indirme
            return
        }
    }

    // MARK: - Merge helper
    private static func mergeDocuments(_ docs: [QueryDocumentSnapshot], context: ModelContext) async throws {
        for doc in docs {
            let data = doc.data()

            // id her zaman non-optional olacak şekilde çıkar
            let id: String = (data["id"] as? String) ?? doc.documentID

            guard
                let title = data["title"] as? String,
                let statusRaw = data["status"] as? String,
                let isDeleted = data["isDeleted"] as? Bool
            else { continue }

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date.distantPast

            let detail = data["detail"] as? String ?? ""
            let assigneeName = data["assigneeName"] as? String
            let locationName = data["locationName"] as? String
            let deadline = (data["deadline"] as? Timestamp)?.dateValue()
            let status = TaskStatus(rawValue: statusRaw) ?? .planlandi

            let signatureName = data["signatureName"] as? String
            let signatureAt = (data["signatureAt"] as? Timestamp)?.dateValue()

            // Merge-by-id
            let pred = #Predicate<WorkItem> { $0.id == id }
            var fd = FetchDescriptor<WorkItem>(predicate: pred); fd.fetchLimit = 1
            let existing = try? context.fetch(fd).first

            if let t = existing {
                // LWW: remote updatedAt localden eskiyse atla
                if updatedAt < t.updatedAt { continue }
                t.title = title
                t.detail = detail
                t.status = status
                t.assigneeName = assigneeName
                t.locationName = locationName
                t.deadline = deadline
                t.createdAt = createdAt
                t.updatedAt = updatedAt
                t.isDeleted = isDeleted
                t.signatureName = signatureName
                t.signatureAt = signatureAt
            } else {
                let t = WorkItem(
                    id: id,
                    title: title,
                    detail: detail,
                    status: status,
                    assigneeName: assigneeName,
                    locationName: locationName,
                    deadline: deadline,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    isDeleted: isDeleted,
                    signatureName: signatureName,
                    signatureAt: signatureAt
                )
                context.insert(t)
            }
        }
        try context.save()
    }
}
