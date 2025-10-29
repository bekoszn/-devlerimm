//
//  Signature.swift
//  TaskFlow
//

import Foundation

public struct Signature: Codable, Sendable {
    public let signerName: String
    public let signatureId: String
    public let signedAt: Date
    public let verificationURL: URL?
}
