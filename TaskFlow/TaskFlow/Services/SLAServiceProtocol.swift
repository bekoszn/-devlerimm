//
//  SLAServiceProtocol.swift
//  TaskFlow
//

import Foundation

enum SLAState: String, Codable, Sendable {
    case normal
    case warning
    case critical
    case overdue
}

protocol SLAServiceProtocol {
    func evaluate(for task: WorkItem, now: Date) -> SLAState
    func badgeText(for state: SLAState) -> String
}

final class DefaultSLAService: SLAServiceProtocol {
    /// Görevin deadline'ına göre SLA durumunu hesaplar
    func evaluate(for task: WorkItem, now: Date = .now) -> SLAState {
        guard let deadline = task.deadline else { return .normal }

        let remaining = deadline.timeIntervalSince(now)

        switch remaining {
        case let x where x <= 0:
            return .overdue
        case ..<3600.0:
            return .critical        // 1 saatten az
        case ..<(6.0 * 3600.0):
            return .warning         // 6 saatten az
        default:
            return .normal
        }
    }

    func badgeText(for state: SLAState) -> String {
        switch state {
        case .normal:   return "Zamanında"
        case .warning:  return "Yaklaşıyor"
        case .critical: return "Kritik"
        case .overdue:  return "Gecikti"
        }
    }
}

