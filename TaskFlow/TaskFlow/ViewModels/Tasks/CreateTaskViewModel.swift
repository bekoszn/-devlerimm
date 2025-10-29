//
//  CreateTaskViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData

@MainActor
final class CreateTaskViewModel: ObservableObject {
    // Form alanları
    @Published var title: String = ""
    @Published var detail: String = ""
    @Published var assigneeName: String = ""
    @Published var locationName: String = ""
    @Published var deadline: Date = .now.addingTimeInterval(24 * 3600)

    // UI state
    @Published var errorMessage: String?
    @Published var isSaving = false

    // Firestore write-through repository (senin mevcut implementasyonun)
    private let repo: TaskRepositoryProtocol = FirebaseTaskRepository()

    var canSave: Bool {
        !title.trimmed.isEmpty
    }

    /// Görevi oluşturur: önce **lokale** yazar, ardından **Firestore**'a set eder.
    func save(context: ModelContext) async {
        guard canSave else {
            errorMessage = "Başlık zorunludur."
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        // 1) SwiftData objesini oluştur
        let item = WorkItem(
            title: title.trimmed,
            detail: detail.trimmed,
            status: .planlandi,
            assigneeName: assigneeName.trimmed.nonEmpty,
            locationName: locationName.trimmed.nonEmpty,
            deadline: deadline,
            createdAt: .now,
            updatedAt: .now,
            isDeleted: false
        )

        do {
            // 2) Lokale ekle
            context.insert(item)
            try context.save()

            // 3) Firestore'a yaz (write-through)
            try await repo.create(item, in: context)

            // (Opsiyonel) Formu temizlemek istersen:
            // resetForm()

        } catch {
            self.errorMessage = "Görev kaydedilirken hata: \(error.localizedDescription)"
        }
    }

    private func resetForm() {
        title = ""; detail = ""; assigneeName = ""; locationName = ""
        deadline = .now.addingTimeInterval(24 * 3600)
    }
}

// MARK: - Yardımcılar
private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nonEmpty: String? { isEmpty ? nil : self }
}
