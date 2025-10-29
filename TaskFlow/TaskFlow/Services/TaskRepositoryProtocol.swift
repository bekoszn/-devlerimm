//
//  TaskRepositoryProtocol.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 29.10.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftData

// MARK: - RemoteIndex
public struct RemoteIndex: Sendable {
    public let activeIDs: Set<String>
    public let deletedIDs: Set<String>
}

// MARK: - Protocol
protocol TaskRepositoryProtocol {
    func create(_ item: WorkItem, in context: ModelContext) async throws
    func update(_ item: WorkItem, in context: ModelContext) async throws
    func softDelete(id: String, in context: ModelContext) async throws
    func listRemoteIndex() async throws -> RemoteIndex
}

// MARK: - FirebaseTaskRepository
final class FirebaseTaskRepository: TaskRepositoryProtocol {

    private let db = Firestore.firestore()
    /// Tek koleksiyon: "tasks"
    private var col: CollectionReference { db.collection("tasks") }

    // MARK: - Create
    func create(_ item: WorkItem, in context: ModelContext) async throws {
        let doc = col.document(item.id)
        let data = makePayload(from: item)
        try await doc.setData(data, merge: false)
    }

    // MARK: - Update (merge)
    func update(_ item: WorkItem, in context: ModelContext) async throws {
        let doc = col.document(item.id)
        let data = makePayload(from: item)
        try await doc.setData(data, merge: true)
    }

    // MARK: - Soft delete (tombstone)
    func softDelete(id: String, in context: ModelContext) async throws {
        let doc = col.document(id)
        try await doc.updateData([
            "isDeleted": true,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    // MARK: - Remote index (aktif/silinmiş ID setleri)
    func listRemoteIndex() async throws -> RemoteIndex {
        // Çok kullanıcılı senaryoda sadece oturumdaki kullanıcıya ait kayıtları indir.
        var q: Query = col
        if let email = Auth.auth().currentUser?.email?.lowercased(), !email.isEmpty {
            q = q.whereField("ownerEmail", isEqualTo: email)
        }

        let snap = try await q.getDocuments()
        var active = Set<String>()
        var deleted = Set<String>()

        for doc in snap.documents {
            // "isDeleted" alanı yoksa false say (eski kayıt uyumluluğu)
            let isDeleted = (doc.data()["isDeleted"] as? Bool) ?? false
            if isDeleted {
                deleted.insert(doc.documentID)
            } else {
                active.insert(doc.documentID)
            }
        }

        return RemoteIndex(activeIDs: active, deletedIDs: deleted)
    }

    // MARK: - Mapping (WorkItem -> Firestore dictionary)
    /// Firestore’a yazarken enum’ları **rawValue** (String) olarak yazıyoruz.
    private func makePayload(from w: WorkItem) -> [String: Any] {
        var dict: [String: Any] = [
            "id": w.id,
            "title": w.title,
            "detail": w.detail,
            "status": w.status.rawValue,                 // "planned" | "todo" | "inProgress" | "review" | "done"
            "createdAt": Timestamp(date: w.createdAt),
            "updatedAt": Timestamp(date: w.updatedAt),
            "isDeleted": w.isDeleted
        ]

        if let a = w.assigneeName, !a.isEmpty { dict["assigneeName"] = a }
        if let l = w.locationName, !l.isEmpty { dict["locationName"] = l }
        if let d = w.deadline { dict["deadline"] = Timestamp(date: d) }

        // İmza alanları opsiyonel
        if let s = w.signatureName, !s.isEmpty { dict["signatureName"] = s }
        if let sa = w.signatureAt { dict["signatureAt"] = Timestamp(date: sa) }

        // Sahiplik bilgisi (listeleme filtrelemesi için)
        if let email = Auth.auth().currentUser?.email {
            dict["ownerEmail"] = email.lowercased()
        }

        return dict
    }
}
