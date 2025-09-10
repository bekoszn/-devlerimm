//
//  ContentView.swift
//  GörevYonetimUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var vm = TaskViewModel()
    @State private var newTitle: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Yeni görev ekleme alanı
                HStack(spacing: 8) {
                    TextField("Yeni görev…", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(add)
                    Button(action: add) {
                        Label("Ekle", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Görev listesi
                List {
                    ForEach(vm.tasks) { task in
                        TaskRow(task: task) {
                            vm.toggleCompletion(for: task)
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Görevler")
        }
    }

    private func add() {
        vm.addTask(title: newTitle)
        newTitle = ""
    }
}

struct TaskRow: View {
    let task: Task
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, pattern: .solid, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                Text(task.isCompleted ? "Tamamlandı" : "Aktif")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.isCompleted ? "tamamlandı" : "aktif")")
        .accessibilityHint("Durumu değiştirmek için iki kez dokunun.")
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
}
