//
//  TaskWidget.swift
//  Widget13App (Widget Extension)
//  Created by Berke Özgüder on 20.10.2025.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Timeline Entry

struct TaskEntry: TimelineEntry {
    let date: Date
    let items: [TaskItemSnapshot]

    struct TaskItemSnapshot: Identifiable, Hashable {
        let id: UUID
        let title: String
        let isCompleted: Bool
        let dueDate: Date?
    }
}

// MARK: - Provider

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), items: demoItems())
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(date: Date(), items: fetchTop())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = TaskEntry(date: Date(), items: fetchTop())
        // 30 dakikada bir yenile; App Intent çalışınca zaten anında yenileme yapılır.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    // SwiftData'dan son eklenenleri çek
    private func fetchTop(limit: Int = 5) -> [TaskEntry.TaskItemSnapshot] {
        do {
            let container = try SharedModelContainer.make()
            let context = ModelContext(container)

            var desc = FetchDescriptor<TaskItem>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            desc.fetchLimit = limit

            let list = try context.fetch(desc)
            return list.map {
                .init(
                    id: $0.uuid,
                    title: $0.title,
                    isCompleted: $0.isCompleted,
                    dueDate: $0.dueDate
                )
            }
        } catch {
            return demoItems()
        }
    }

    // Widget Gallery ve hata durumları için örnek veri
    private func demoItems() -> [TaskEntry.TaskItemSnapshot] {
        [
            .init(id: UUID(), title: "Örnek Görev 1", isCompleted: false, dueDate: nil),
            .init(id: UUID(), title: "Örnek Görev 2", isCompleted: true, dueDate: Date().addingTimeInterval(86_400))
        ]
    }
}

// MARK: - View

struct TaskWidgetEntryView: View {
    var entry: TaskProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Görevler")
                    .font(.headline)
                Spacer()

                // Hızlı ekleme (opsiyonel intent)
                Button(intent: AddQuickTaskIntent(title: "Quick Task")) {
                    Image(systemName: "plus.circle.fill")
                }
                .labelStyle(.iconOnly)
                .tint(.accentColor)
            }

            if entry.items.isEmpty {
                Text("Henüz görev yok")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entry.items.prefix(4)) { item in
                    HStack(spacing: 8) {
                        Button(intent: ToggleTaskIntent(taskUUID: item.id.uuidString)) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .labelStyle(.iconOnly)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .lineLimit(1)
                                .font(.subheadline)
                                .strikethrough(item.isCompleted, color: .secondary)

                            if let due = item.dueDate {
                                Text(due, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }

                if entry.items.count > 4 {
                    Text("…")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .padding(12)
    }
}

// MARK: - Widget

struct TaskWidget: Widget {
    let kind: String = "TaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Görevlerim")
        .description("Görevleri görüntüle ve tek dokunuşla tamamla/geri al.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}


#if DEBUG
struct TaskWidget_Previews: PreviewProvider {
    static var previews: some View {
        TaskWidgetEntryView(
            entry: TaskEntry(
                date: .now,
                items: [
                    .init(id: .init(), title: "UI tasarımını bitir", isCompleted: false, dueDate: .now),
                    .init(id: .init(), title: "Bugfix: Crash on launch", isCompleted: true, dueDate: nil)
                ]
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
