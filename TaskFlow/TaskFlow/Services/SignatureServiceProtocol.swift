//
//  SignatureServiceProtocol.swift
//  TaskFlow
//

import Foundation

protocol SignatureServiceProtocol {
    func sign(task: WorkItem, signerName: String) async throws -> Signature
}

// Demo/Stub implementasyon (gerçek entegrasyon olana kadar)
final class StubSignatureService: SignatureServiceProtocol {
    func sign(task: WorkItem, signerName: String) async throws -> Signature {
        try await Task.sleep(nanoseconds: 300_000_000) // küçük görsel gecikme
        let id = "SIG-\(UUID().uuidString.prefix(8))"
        let url = URL(string: "https://sign.taskflow.app/verify/\(task.id)")
        return Signature(
            signerName: signerName,
            signatureId: String(id),
            signedAt: .now,
            verificationURL: url
        )
    }
}

