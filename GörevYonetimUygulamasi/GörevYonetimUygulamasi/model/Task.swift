//
//  Task.swift
//  GörevYonetimUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI


struct Task: Identifiable, Equatable {
let id: UUID
var title: String
var isCompleted: Bool

init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
self.id = id
self.title = title
self.isCompleted = isCompleted
    }
}
