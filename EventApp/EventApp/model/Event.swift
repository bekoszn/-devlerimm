//
//  Event.swift
//  EventApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct Event: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var type: EventType
    var hasReminder: Bool

    init(id: UUID = UUID(), title: String, date: Date = .now, type: EventType = .other, hasReminder: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.hasReminder = hasReminder
    }
}

enum EventType: String, CaseIterable, Identifiable, Codable {
    case birthday = "Doğum Günü"
    case meeting = "Toplantı"
    case holiday = "Tatil"
    case sport = "Spor"
    case other = "Diğer"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .birthday: return "gift"
        case .meeting: return "person.2"
        case .holiday: return "sun.max"
        case .sport: return "figure.run"
        case .other: return "calendar"
        }
    }
}
