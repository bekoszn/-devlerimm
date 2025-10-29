//
//  TaskListViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class TaskListViewModel: ObservableObject {
    enum LoadState { case idle, loading, loaded, failed(String) }

    @Published private(set) var tasks: [WorkItem] = []
    @Published private(set) var state: LoadState = .idle
    @Published var searchText: String = ""
    @Published var statusFilter: TaskStatus? = nil
    @Published private(set) var isBusy = false
    @Published private(set) var isAdmin = false
    @Published var errorMessage: String?

    // Admin e-posta listesi
    private let ADMIN_EMAILS: Set<String> = [
        "brkzgdr@gmail.com",
    ]

    // Firestore write-through
    private let repo: TaskRepositoryProtocol = FirebaseTaskRepository()
    private let db = Firestore.firestore()

    init() {}

    // MARK: - Identity
    private var currentDisplayName: String? {
        if let d = Auth.auth().currentUser?.displayName, !d.trimmingCharacters(in: .whitespaces).isEmpty {
            return d
        }
        if let mail = Auth.auth().currentUser?.email,
           let beforeAt = mail.split(separator: "@").first {
            return String(beforeAt)
        }
        return nil
    }

    func resolveAdmin() async {
        let email = Auth.auth().currentUser?.email?.lowercased()
        isAdmin = email.map { ADMIN_EMAILS.contains($0) } ?? false
    }

    // MARK: - Data

    /// SwiftData’dan oku; admin değilse assigneeName == currentDisplayName olanlarla sınırla
    func refresh(context: ModelContext) async {
        state = .loading
        errorMessage = nil
        do {
            let fd = FetchDescriptor<WorkItem>(
                predicate: #Predicate { $0.isDeleted == false },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            let all = try context.fetch(fd)

            if isAdmin {
                tasks = all
            } else if let me = currentDisplayName?.lowercased() {
                tasks = all.filter { ($0.assigneeName?.lowercased() ?? "") == me }
            } else {
                tasks = []
            }

            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    var filtered: [WorkItem] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return tasks
            .filter { t in
                let statusOK = statusFilter == nil || t.status == statusFilter
                let searchOK = text.isEmpty
                    || t.title.localizedCaseInsensitiveContains(text)
                    || t.detail.localizedCaseInsensitiveContains(text)
                    || (t.assigneeName ?? "").localizedCaseInsensitiveContains(text)
                    || (t.locationName ?? "").localizedCaseInsensitiveContains(text)
                return statusOK && searchOK
            }
            .sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    // Hızlı durum ilerletme (local + Firestore merge)
    func quickAdvance(_ item: WorkItem, context: ModelContext) async {
        guard let next = item.status.next() else { return }
        isBusy = true
        defer { isBusy = false }
        item.status = next
        item.updatedAt = .now
        do {
            try context.save()
            try await repo.update(item, in: context)
        } catch {
            errorMessage = "Durum güncellenemedi: \(error.localizedDescription)"
        }
    }

    // HARD DELETE — SADECE ADMIN
    /// Hem SwiftData’dan hem Firestore’dan SİLER (tombstone değil).
    func quickDelete(_ item: WorkItem, context: ModelContext) async {
        guard isAdmin else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }

        do {
            // 1) Firestore’dan kalıcı sil
            try await db.collection(WorkItemDTO.collection).document(item.id).delete()

            // 2) SwiftData’dan kalıcı sil
            context.delete(item)
            try context.save()

            // 3) Listeyi tazele
            await refresh(context: context)
        } catch {
            errorMessage = "Silme başarısız: \(error.localizedDescription)"
        }
    }
}
