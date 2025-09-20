//
//  PreviewBootstrapper.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//


import SwiftUI
import CoreData

struct PreviewBootstrapper {
    static func inMemoryContainer() -> NSPersistentContainer {
        let pc = PersistenceController(inMemory: true)
        return pc.container
    }
}

#Preview("Liste") {
    let c = PreviewBootstrapper.inMemoryContainer()
    let moc = c.viewContext

    // Örnek kayıtlar
    for (t, ctn) in [
        ("Alışveriş Listesi", "Yumurta, süt, ekmek"),
        ("SwiftUI Notları", "@FetchRequest, sheet, NavigationStack"),
        ("Tekrar Planı", "Pazartesi Core Data, Salı Combine…")
    ] {
        let n = Note(context: moc)
        n.id = UUID(); n.title = t; n.content = ctn; n.date = Date()
    }
    try? moc.save()

    return ContentView().environment(\.managedObjectContext, moc)
}

#Preview("Detay") {
    let c = PreviewBootstrapper.inMemoryContainer()
    let moc = c.viewContext

    let n = Note(context: moc)
    n.id = UUID(); n.title = "Örnek"; n.content = "Örnek içerik"; n.date = Date()
    try? moc.save()

    return NavigationStack {
        NoteDetailView(objectID: n.objectID)
            .environment(\.managedObjectContext, moc)
    }
}

