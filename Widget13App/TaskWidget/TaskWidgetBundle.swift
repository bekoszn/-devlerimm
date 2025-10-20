//
//  TaskWidgetBundle.swift
//  TaskWidget
//
//  Created by Berke Özgüder on 20.10.2025.
//

import WidgetKit
import SwiftUI

@main
struct TaskWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TaskWidget()
        TaskWidgetLiveActivity()
        if #available(iOS 18.0, *) {
            TaskWidgetControl()
        }
    }
}
