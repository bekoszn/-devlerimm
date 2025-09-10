//
//  TaskViewModel.swift
//  GörevYonetimUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

final class TaskViewModel: ObservableObject {
@Published private(set) var tasks: [Task] = []

init(seed: Bool = true) {
if seed {
tasks = [
Task(title: "Sunum hazırlıklarını bitir"),
Task(title: "Unit test yaz"),
Task(title: "SwiftUI List makalesini oku", isCompleted: true)]
    }
}

func addTask(title: String) {
let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
guard !trimmed.isEmpty else { return }
tasks.insert(Task(title: trimmed), at: 0)
    }

func toggleCompletion(for task: Task) {
guard let idx = tasks.firstIndex(of: task) else { return }
tasks[idx].isCompleted.toggle()
    }

func delete(at offsets: IndexSet) {
tasks.remove(atOffsets: offsets)
    }
}
