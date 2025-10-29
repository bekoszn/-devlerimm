//
//  DashboardViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var taskCount = 0
    @Published private(set) var warningCount = 0
    @Published private(set) var criticalCount = 0
    @Published private(set) var isAdmin = false

    private let ADMIN_EMAILS: Set<String> = [
        "brkzgdr@gmail.com",
    ]

    private let repo: TaskRepositoryProtocol = FirebaseTaskRepository()

    func initialLoad(context: ModelContext) async {
        await refreshNow(context: context)
        await resolveAdmin()
    }

    func refreshNow(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let d = FetchDescriptor<WorkItem>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
            let items = try context.fetch(d)
            taskCount = items.count

            var warn = 0, crit = 0
            for t in items {
                switch slaState(for: t) {
                case .warning: warn += 1
                case .critical, .overdue: crit += 1
                case .ok: break
                }
            }
            warningCount = warn
            criticalCount = crit
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resolveAdmin() async {
        let email = Auth.auth().currentUser?.email?.lowercased()
        isAdmin = email.map { ADMIN_EMAILS.contains($0) } ?? false
    }

    // MARK: - TÜMÜNÜ SİL (Local + Firebase) — YALNIZCA ADMIN
    /// SwiftData’daki TÜM WorkItem’ları ve Firestore’daki TÜM dokümanları kalıcı olarak siler.
    func purgeAll(context: ModelContext) async {
        guard isAdmin else {
            errorMessage = "Bu işlemi yalnızca yöneticiler yapabilir."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 1) Firestore — tüm dokümanları sil (batched)
            let db = Firestore.firestore()
            let col = db.collection(WorkItemDTO.collection) // "workItems"

            // Hepsini çek
            let snap = try await col.getDocuments()

            // 400’lük batch’lerle sil
            var toDelete = snap.documents
            while !toDelete.isEmpty {
                let chunk = Array(toDelete.prefix(400))
                toDelete.removeFirst(min(400, toDelete.count))

                let batch = db.batch()
                for doc in chunk {
                    batch.deleteDocument(doc.reference)
                }
                try await batch.commit()
            }

            // 2) SwiftData — tüm WorkItem’ları sil
            let d = FetchDescriptor<WorkItem>()
            let localItems = try context.fetch(d)
            for item in localItems {
                context.delete(item)
            }
            try context.save()

            // 3) Sayaçları yenile
            await refreshNow(context: context)
        } catch {
            errorMessage = "Toplu silme başarısız: \(error.localizedDescription)"
        }
    }

    // MARK: - SLA
    private enum SLAState { case ok, warning, critical, overdue }
    private func slaState(for task: WorkItem) -> SLAState {
        guard let deadline = task.deadline else { return .ok }
        let now = Date()
        if deadline < now { return .overdue }
        let remaining = deadline.timeIntervalSince(now)

        let oneHour: TimeInterval = 60 * 60
        let sixHours: TimeInterval = 6 * oneHour
        if remaining <= oneHour { return .critical }
        if remaining <= sixHours { return .warning }
        return .ok
    }
}
