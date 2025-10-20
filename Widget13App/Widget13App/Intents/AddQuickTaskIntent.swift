//
//  Intents.swift
//  Widget13AppIntents
//
//  Created by Berke Özgüder on 20.10.2025.
//

import AppIntents
import SwiftData
import WidgetKit
import Foundation

struct AddQuickTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Quick Task"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Title")
    var title: String

    init() {}

    init(title: String) {
        self.init()
        // Assign to the wrapped property instead of the backing storage
        self.title = title
    }

    func perform() async throws -> some IntentResult {
        do {
            let container = try SharedModelContainer.make()
            let context = ModelContext(container)
            let item = TaskItem(title: title)
            context.insert(item)
            try context.save()
        } catch {
            // You might want to log the error in debug builds
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Task UUID")
    var taskUUID: String

    init() {}

    init(taskUUID: String) {
        self.init()
        // Assign to the wrapped property instead of the backing storage
        self.taskUUID = taskUUID
    }

    func perform() async throws -> some IntentResult {
        do {
            let container = try SharedModelContainer.make()
            let context = ModelContext(container)

            // Safely unwrap the UUID string before building the predicate
            if let id = UUID(uuidString: taskUUID) {
                let request = FetchDescriptor<TaskItem>(
                    predicate: #Predicate { $0.uuid == id }
                )
                if let task = try context.fetch(request).first {
                    task.isCompleted.toggle()
                    try context.save()
                }
            }
        } catch {
            // You might want to log the error in debug builds
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
