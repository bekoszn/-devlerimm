//
//  TaskWidgetControl.swift
//  TaskWidget (Widget Extension)
//  Created by Berke Özgüder on 20.10.2025.
//

import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Control Widget (iOS 18)

@available(iOS 18.0, *)
struct TaskWidgetControl: ControlWidget {
    static let kind: String = "bekoszn.Widget13App.TaskWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(name: value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("An example control that runs a timer.")
    }
}

// MARK: - Control Value + Provider

@available(iOS 18.0, *)
extension TaskWidgetControl {

    struct Value: Equatable, Sendable {
        var isRunning: Bool
        var name: String
    }

    struct Provider: AppIntentControlValueProvider {
        typealias Configuration = TimerConfiguration
        typealias Value = TaskWidgetControl.Value

        func previewValue(configuration: TimerConfiguration) -> Value {
            .init(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = false
            return .init(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

// MARK: - Configuration Intent

@available(iOS 18.0, *)
struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Configuration"

    @Parameter(title: "Timer Name", default: "Timer")
    var timerName: String
}

// MARK: - SetValueIntent

@available(iOS 18.0, *)
struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start/Stop Timer"

    @Parameter(title: "Timer Name")
    var name: String

    @Parameter(title: "Timer is running")
    var value: Bool

    init() {}

    init(name: String) {
        self.name = name
        self.value = false
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$name) running to \(\.$value)")
    }

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
