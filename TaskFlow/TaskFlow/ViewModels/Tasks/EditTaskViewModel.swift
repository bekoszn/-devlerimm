//
//  EditTaskViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData

@MainActor
final class EditTaskViewModel: ObservableObject {
    @Published private(set) var original: WorkItem?
    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var assigneeName: String = ""
    @Published var locationName: String = ""
    @Published var deadline: Date = .now
    @Published var status: TaskStatus = .planlandi
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var isLoading = false

    let taskID: String

    init(taskID: String) { self.taskID = taskID }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func load(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let pred = #Predicate<WorkItem> { $0.id == taskID }
            var fd = FetchDescriptor<WorkItem>(predicate: pred)
            fd.fetchLimit = 1
            guard let t = try context.fetch(fd).first else {
                errorMessage = "Görev bulunamadı."
                return
            }
            apply(from: t)
            errorMessage = nil
        } catch {
            errorMessage = "Görev yüklenemedi: \(error.localizedDescription)"
        }
    }

    func save(context: ModelContext) async {
        guard canSave else {
            errorMessage = "Başlık zorunludur."
            return
        }
        isSaving = true
        defer { isSaving = false }

        do {
            let pred = #Predicate<WorkItem> { $0.id == taskID }
            var fd = FetchDescriptor<WorkItem>(predicate: pred)
            fd.fetchLimit = 1
            guard let t = try context.fetch(fd).first else {
                errorMessage = "Görev bulunamadı."
                return
            }

            t.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            t.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
            t.status = status
            t.assigneeName = assigneeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : assigneeName
            t.locationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : locationName
            t.deadline = deadline
            t.updatedAt = .now

            try context.save()
            apply(from: t)   // ekranda güncel değerleri göster
            errorMessage = nil
        } catch {
            errorMessage = "Görev güncellenemedi: \(error.localizedDescription)"
        }
    }

    private func apply(from t: WorkItem) {
        original = t
        title = t.title
        detail = t.detail
        assigneeName = t.assigneeName ?? ""
        locationName = t.locationName ?? ""
        deadline = t.deadline ?? .now
        status = t.status
    }
}
