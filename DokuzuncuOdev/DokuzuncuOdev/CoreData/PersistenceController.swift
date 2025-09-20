//
//  PersistenceController.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//


import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // 1) Bundle'dan model yüklemeyi dene
        if let url = Bundle.main.url(forResource: "NotesModel", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: url) {
            container = NSPersistentContainer(name: "NotesModel", managedObjectModel: model)
        } else {
            // 2) Fallback: Programatik model kur
            let model = Self.makeModel()
            container = NSPersistentContainer(name: "NotesModel", managedObjectModel: model)
        }

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Unresolved Core Data error: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "Note"
        entity.managedObjectClassName = NSStringFromClass(Note.self)

        let id = NSAttributeDescription(); id.name = "id"; id.attributeType = .UUIDAttributeType; id.isOptional = true
        let title = NSAttributeDescription(); title.name = "title"; title.attributeType = .stringAttributeType; title.isOptional = true
        let content = NSAttributeDescription(); content.name = "content"; content.attributeType = .stringAttributeType; content.isOptional = true
        let date = NSAttributeDescription(); date.name = "date"; date.attributeType = .dateAttributeType; date.isOptional = true

        entity.properties = [id, title, content, date]
        model.entities = [entity]
        return model
    }
}

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        do { try save() } catch { print("❌ CoreData save error:", error) }
    }
}
