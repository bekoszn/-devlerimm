//
//  NotificationService.swift
//  TaskFlow
//

import Foundation
import UserNotifications

// Protokolün Sendable ise bu struct otomatik Sendable uyumlu olur.
struct NotificationService: NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Bool, Error>) in
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { ok, err in
                    if let err { cont.resume(throwing: err) }
                    else { cont.resume(returning: ok) }
                }
        }
    }

    func scheduleSLAAlarms(
        for task: WorkItemSnapshot,
        warnBefore: TimeInterval,
        criticalBefore: TimeInterval
    ) async throws {
        // Güven için gerekli alanları snapshot et
        let taskId   = task.id
        let title    = task.title
        guard let deadline = task.deadline else { return }

        // Önce eski bildirimleri temizle
        await cancelSLAAlarms(for: taskId)

        let now          = Date()
        let warningDate  = deadline.addingTimeInterval(-warnBefore)
        let criticalDate = deadline.addingTimeInterval(-criticalBefore)

        let center = UNUserNotificationCenter.current()

        try await withThrowingTaskGroup(of: Void.self) { group in
            if warningDate > now {
                let req = makeRequest(
                    id: makeId(taskId: taskId, tag: "warn"),
                    title: "SLA Uyarı",
                    body: "“\(title)” için \(Int(warnBefore/3600)) saat kaldı.",
                    fireAt: warningDate
                )
                group.addTask { try await add(req, to: center) }
            }

            if criticalDate > now {
                let req = makeRequest(
                    id: makeId(taskId: taskId, tag: "critical"),
                    title: "SLA Kritik",
                    body: "“\(title)” için \(Int(criticalBefore/60)) dakika kaldı!",
                    fireAt: criticalDate
                )
                group.addTask { try await add(req, to: center) }
            }

            if deadline > now {
                let req = makeRequest(
                    id: makeId(taskId: taskId, tag: "deadline"),
                    title: "SLA Süresi Doldu",
                    body: "“\(title)” görevinin süresi doldu.",
                    fireAt: deadline
                )
                group.addTask { try await add(req, to: center) }
            }

            try await group.waitForAll()
        }
    }

    func cancelSLAAlarms(for taskId: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["warn","critical","deadline"].map { makeId(taskId: taskId, tag: $0) }
        )
    }

    // MARK: - Helpers

    private func makeId(taskId: String, tag: String) -> String { "task.\(taskId).sla.\(tag)" }

    private func makeRequest(id: String, title: String, body: String, fireAt: Date) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: fireAt)
        comps.timeZone = .current

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }

    /// UNUserNotificationCenter.add(_:completionHandler:) -> async/throwing sarmalayıcı
    private func add(_ request: UNNotificationRequest, to center: UNUserNotificationCenter) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }
}
