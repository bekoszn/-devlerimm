//
//  ForgotPasswordViewModel.swift
//  TaskFlow
//

import Foundation
import Combine

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var infoMessage: String?
    @Published var errorMessage: String?

    // Doğrudan repo (DI yok)
    private let auth = FirebaseAuthRepository()

    func sendReset() async {
        guard isValidEmail(email) else {
            errorMessage = "Geçerli bir e-posta girin."
            infoMessage = nil
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.sendPasswordReset(email: email)
            errorMessage = nil
            infoMessage = "Sıfırlama bağlantısı e-postanıza gönderildi."
        } catch {
            infoMessage = nil
            errorMessage = error.localizedDescription
        }
    }

    // Basit ama yeterli bir e-posta kontrolü
    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 6
    }
}
