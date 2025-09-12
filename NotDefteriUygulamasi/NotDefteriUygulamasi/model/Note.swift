//
//  Note.swift
//  NotDefteriUygulamasi
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct Note: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var date: Date

    init(id: UUID = UUID(), title: String, content: String, date: Date = .now) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
    }
}
