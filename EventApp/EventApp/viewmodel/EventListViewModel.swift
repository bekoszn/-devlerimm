//
//  EventListViewModel.swift
//  EventApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

final class EventListViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []

    init(seed: Bool = true) {
        if seed {
            events = [
                Event(title: "Berke'nin Doğum Günü", date: .now.addingTimeInterval(86400*3), type: .birthday, hasReminder: true),
                Event(title: "iOS Standup", date: .now.addingTimeInterval(86400), type: .meeting),
                Event(title: "Kısa Tatil", date: .now.addingTimeInterval(86400*14), type: .holiday),
                Event(title: "Koşu", date: .now.addingTimeInterval(86400*5), type: .sport)
            ]
        }
    }

    func add(title: String, date: Date, type: EventType, hasReminder: Bool) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        events.insert(Event(title: t, date: date, type: type, hasReminder: hasReminder), at: 0)
    }

    func delete(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
    }

    func delete(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }

    func toggleReminder(for event: Event) {
        guard let idx = events.firstIndex(of: event) else { return }
        events[idx].hasReminder.toggle()
    }
}
