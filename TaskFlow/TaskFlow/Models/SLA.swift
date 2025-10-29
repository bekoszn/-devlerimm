//
//  SLA.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


//
//  SLA.swift
//  TaskFlow
//

import Foundation

struct SLA: Codable, Hashable {
    var deadline: Date?
    var warnThresholdHours: Double = 24
    var criticalThresholdHours: Double = 6

    enum State: String, Codable, Hashable { case normal, warning, critical, overdue }

    func state(now: Date = .now) -> State {
        guard let deadline else { return .normal }
        let remaining = deadline.timeIntervalSince(now) / 3600.0
        if remaining < 0 { return .overdue }
        if remaining <= criticalThresholdHours { return .critical }
        if remaining <= warnThresholdHours { return .warning }
        return .normal
    }
}
