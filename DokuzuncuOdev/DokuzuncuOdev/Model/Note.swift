//
//  Note.swift
//  DokuzuncuOdev
//
//  Created by Berke Özgüder on 18.09.2025.
//


import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {}

extension Note {
@nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
return NSFetchRequest<Note>(entityName: "Note")
}

@NSManaged public var id: UUID?
@NSManaged public var title: String?
@NSManaged public var content: String?
@NSManaged public var date: Date?
}