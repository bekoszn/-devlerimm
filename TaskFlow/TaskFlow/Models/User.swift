//
//  User.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


//
//  User.swift
//  TaskFlow
//

import Foundation

struct User: Identifiable, Codable, Hashable, Sendable {
    var id: String                // Firebase UID
    var email: String
    var displayName: String
    var role: Role

    init(id: String,
         email: String,
         displayName: String,
         role: Role = .worker) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
    }
}

extension User {
    static let placeholder = User(id: "demo-uid",
                                  email: "demo@taskflow.app",
                                  displayName: "Demo User",
                                  role: .worker)
}
