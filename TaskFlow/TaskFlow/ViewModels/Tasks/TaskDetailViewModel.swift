//
//  TaskDetailViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published private(set) var task: WorkItem?
    @Published var isBusy = false
    @Published var errorMessage: String?

    // Firestore write-through repository
    private let repo: TaskRepositoryProtocol = FirebaseTaskRepository()

    let taskID: String
    init(taskID: String) { self.taskID = taskID }

    func load(context: ModelContext) async {
        isBusy = true
        defer { isBusy = false }
        do {
            let pred = #Predicate<WorkItem> { $0.id == taskID && $0.isDeleted == false }
            var fd = FetchDescriptor<WorkItem>(predicate: pred)
            fd.fetchLimit = 1
            self.task = try context.fetch(fd).first
            if task == nil {
                errorMessage = "Görev bulunamadı."
            } else {
                errorMessage = nil
            }
        } catch {
            errorMessage = "Görev yüklenemedi: \(error.localizedDescription)"
        }
    }

    func advance(context: ModelContext) async {
        guard let t = task, let next = t.status.next() else { return }
        await updateStatus(to: next, context: context)
    }

    func rewind(context: ModelContext) async {
        guard let t = task, let prev = t.status.previous() else { return }
        await updateStatus(to: prev, context: context)
    }

    // MARK: - Private

    private func updateStatus(to newStatus: TaskStatus, context: ModelContext) async {
        guard var t = task else { return }
        isBusy = true
        defer { isBusy = false }

        t.status = newStatus
        t.updatedAt = .now

        do {
            try context.save()               // lokal
            try await repo.update(t, in: context) // remote (Firestore)
            task = t                         // UI’ı güncelle
            errorMessage = nil
        } catch {
            errorMessage = "Güncelleme hatası: \(error.localizedDescription)"
        }
    }
}
