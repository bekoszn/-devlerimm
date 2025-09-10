//
//  TaskListViewModel.swift
//  MasterListApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

final class TaskListViewModel: ObservableObject {
@Published var items: [TaskItem]

init(seed: Bool = true) {
if seed {
self.items = (1...10).map { i in
TaskItem(title: "Öğe #\(i)", detail: "Bu, \(i). öğenin açıklamasıdır.", isDone: i % 3 == 0)
    }
    } else {
self.items = []
        
        }
    }

func addItem(title: String, detail: String) {
let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
guard !t.isEmpty else { return }
let d = detail.trimmingCharacters(in: .whitespacesAndNewlines)
items.insert(TaskItem(title: t, detail: d), at: 0)
    
    }

func delete(at offsets: IndexSet, inDoneSection: Bool) {
let filtered = items.enumerated().filter { $0.element.isDone == inDoneSection }
let idsToDelete: [UUID] = offsets.compactMap { idx in filtered[idx].element.id }
items.removeAll { idsToDelete.contains($0.id) }
    
    }

func deleteItems(_ ids: Set<UUID>) {
items.removeAll { ids.contains($0.id) }
    
    }

func toggleDone(_ item: TaskItem) {
guard let idx = items.firstIndex(of: item) else { return }
items[idx].isDone.toggle()
    }
}
