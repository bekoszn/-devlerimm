//
//  NotificationServiceProtocol.swift
//  TaskFlow
//

import Foundation

public protocol NotificationServiceProtocol: Sendable {
    /// iOS bildirim izni iste
    func requestAuthorization() async throws -> Bool

    /// Verilen görev için SLA uyarılarını planla (deadline yoksa hiçbir şey yapmaz)
    func scheduleSLAAlarms(for task: WorkItemSnapshot,
                           warnBefore: TimeInterval,
                           criticalBefore: TimeInterval) async throws

    /// Göreve ait planlı SLA bildirimlerini iptal et
    func cancelSLAAlarms(for taskId: String) async
}
