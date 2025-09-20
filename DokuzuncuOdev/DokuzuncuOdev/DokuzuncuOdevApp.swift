//
//  DokuzuncuOdevApp.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//

import SwiftUI

@main
struct DokuzuncuOdevApp: App {
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
