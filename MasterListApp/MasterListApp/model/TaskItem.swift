//
//  TaskItem.swift
//  MasterListApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct TaskItem: Identifiable, Equatable, Hashable {
let id: UUID
var title: String
var detail: String
var isDone: Bool

init(id: UUID = UUID(), title: String, detail: String = "", isDone: Bool = false) {
self.id = id
self.title = title
self.detail = detail
self.isDone = isDone
    
    }
}
