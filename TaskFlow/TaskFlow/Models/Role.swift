//
//  Role.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 22.10.2025.
//


//
//  Role.swift
//  TaskFlow
//

import Foundation

enum Role: String, Codable, Sendable {
    case admin
    case worker

    var canCreateTask: Bool { self == .admin }
}
