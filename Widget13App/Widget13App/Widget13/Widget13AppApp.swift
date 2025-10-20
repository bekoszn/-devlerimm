//
//  Widget13AppApp.swift
//  Widget13App
//
//  Created by Berke Özgüder on 20.10.2025.
//

import SwiftUI
import SwiftData

@main
struct Widget13AppApp: App {
    // Create the shared container once
    private let container: ModelContainer = {
        do {
            return try SharedModelContainer.make()
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Pass the prebuilt container to the correct overload
        .modelContainer(container)
    }
}
