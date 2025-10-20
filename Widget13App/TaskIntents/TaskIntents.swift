//
//  TaskIntents.swift
//  TaskIntents
//
//  Created by Berke Özgüder on 20.10.2025.
//

import AppIntents

struct TaskIntents: AppIntent {
    static var title: LocalizedStringResource { "TaskIntents" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
