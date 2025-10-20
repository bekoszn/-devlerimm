//
//  Models.swift
//  Widget13App
//
//  Created by Berke Özgüder on 20.10.2025.
//


import SwiftData
import Foundation

@Model
final class TaskItem {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?

    init(title: String, isCompleted: Bool = false, dueDate: Date? = nil) {
        self.uuid = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.dueDate = dueDate
    }
}
