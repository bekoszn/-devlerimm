//
//  ContentView.swift
//  Widget13App
//
//  Created by Berke Özgüder on 20.10.2025.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var newTitle: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Yeni görev ekle...", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("Ekle") { addTask() }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                List {
                    ForEach(tasks) { task in
                        HStack {
                            Button {
                                toggle(task)
                            } label: {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .strikethrough(task.isCompleted, color: .secondary)
                                if let due = task.dueDate {
                                    Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Görevlerim")
        }
    }

    private func addTask() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = TaskItem(title: trimmed)
        context.insert(item)
        try? context.save()
        newTitle = ""
    }

    private func toggle(_ task: TaskItem) {
        task.isCompleted.toggle()
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { context.delete(tasks[i]) }
        try? context.save()
    }
}
