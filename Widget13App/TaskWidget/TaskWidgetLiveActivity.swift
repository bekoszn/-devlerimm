//
//  TaskWidgetLiveActivity.swift
//  TaskWidget
//
//  Created by Berke Özgüder on 20.10.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TaskWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TaskWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TaskWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TaskWidgetAttributes {
    fileprivate static var preview: TaskWidgetAttributes {
        TaskWidgetAttributes(name: "World")
    }
}

extension TaskWidgetAttributes.ContentState {
    fileprivate static var smiley: TaskWidgetAttributes.ContentState {
        TaskWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TaskWidgetAttributes.ContentState {
         TaskWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TaskWidgetAttributes.preview) {
   TaskWidgetLiveActivity()
} contentStates: {
    TaskWidgetAttributes.ContentState.smiley
    TaskWidgetAttributes.ContentState.starEyes
}
