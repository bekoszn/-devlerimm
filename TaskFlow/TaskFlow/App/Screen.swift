//
//  Screen.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 26.10.2025.
//

import Foundation

enum Screen: Hashable {
    case dashboard
    case taskList
    case createTask
    case taskDetail(id: String)
    case signature(id: String)
    case pdfPreview(id: String)
    case settings
}
