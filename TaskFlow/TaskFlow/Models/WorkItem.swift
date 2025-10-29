//
//  WorkItem.swift
//  TaskFlow
//

import Foundation
import SwiftData
import FirebaseFirestore
// MARK: - SwiftData Model

@Model
final class WorkItem {
    @Attribute(.unique) var id: String
    var title: String
    var detail: String
    var status: TaskStatus
    var assigneeName: String?
    var locationName: String?
    var deadline: Date?
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool

    // İmza alanları (opsiyonel kullanım)
    var signatureName: String?
    var signatureAt: Date?

    init(
        id: String = UUID().uuidString,
        title: String,
        detail: String = "",
        status: TaskStatus = .planlandi,
        assigneeName: String? = nil,
        locationName: String? = nil,
        deadline: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isDeleted: Bool = false,
        signatureName: String? = nil,
        signatureAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.status = status
        self.assigneeName = assigneeName
        self.locationName = locationName
        self.deadline = deadline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
        self.signatureName = signatureName
        self.signatureAt = signatureAt
    }
}

// MARK: - Snapshot (opsiyonel)

public struct WorkItemSnapshot: Sendable, Codable {
    public let id: String
    public let title: String
    public let detail: String
    public let status: TaskStatus
    public let assigneeName: String?
    public let locationName: String?
    public let deadline: Date?
    public let signatureName: String?
    public let signatureAt: Date?
}

extension WorkItem {
    var snapshot: WorkItemSnapshot {
        .init(id: id,
              title: title,
              detail: detail,
              status: status,
              assigneeName: assigneeName,
              locationName: locationName,
              deadline: deadline,
              signatureName: signatureName,
              signatureAt: signatureAt)
    }
}

// MARK: - Firestore DTO

struct WorkItemDTO: Codable {
    var id: String
    var title: String
    var detail: String
    var status: String                 // Firestore’da string
    var assigneeName: String?
    var locationName: String?
    var deadline: Timestamp?

    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?

    var isDeleted: Bool

    var signatureName: String?
    var signatureAt: Timestamp?

    static let collection = "tasks"
}

// MARK: - DTO ↔︎ SwiftData WorkItem dönüşümleri

extension WorkItemDTO {
    init(from item: WorkItem) {
        self.id = item.id
        self.title = item.title
        self.detail = item.detail
        self.status = item.status.rawValue
        self.assigneeName = item.assigneeName
        self.locationName = item.locationName
        self.deadline = item.deadline.map { Timestamp(date: $0) }
        self.createdAt = Timestamp(date: item.createdAt)
        self.updatedAt = Timestamp(date: item.updatedAt)
        self.isDeleted = item.isDeleted
        self.signatureName = item.signatureName
        self.signatureAt = item.signatureAt.map { Timestamp(date: $0) }
    }

    /// DTO verisini mevcut (veya yeni) WorkItem’a uygula (LWW: updatedAt’e göre)
    func apply(to existing: WorkItem?) -> WorkItem {
        let obj: WorkItem = existing ?? WorkItem(
            id: id,
            title: title,
            detail: detail,
            status: TaskStatus(rawValue: status) ?? .planlandi,
            assigneeName: assigneeName,
            locationName: locationName,
            deadline: deadline?.dateValue(),
            createdAt: createdAt?.dateValue() ?? Date(),
            updatedAt: updatedAt?.dateValue() ?? Date(),
            isDeleted: isDeleted,
            signatureName: signatureName,
            signatureAt: signatureAt?.dateValue()
        )

        // LWW: remote updatedAt localden eskiyse atla
        if let remoteUpdated = self.updatedAt?.dateValue(),
           remoteUpdated < obj.updatedAt {
            return obj
        }

        obj.title = title
        obj.detail = detail
        obj.status = TaskStatus(rawValue: status) ?? obj.status
        obj.assigneeName = assigneeName
        obj.locationName = locationName
        obj.deadline = deadline?.dateValue()

        if let c = createdAt?.dateValue() { obj.createdAt = c }
        if let u = updatedAt?.dateValue() { obj.updatedAt = u }

        obj.isDeleted = isDeleted
        obj.signatureName = signatureName
        obj.signatureAt = signatureAt?.dateValue()

        return obj
    }
}
