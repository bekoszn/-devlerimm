//
//  RegisterViewModel.swift
//  TaskFlow
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var agreeTOS: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth = FirebaseAuthRepository()

    func signUp() async {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.signUp(fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                                  email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                  password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validate() -> Bool {
        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Tüm alanlar zorunludur."
            return false
        }
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Geçerli bir e-posta girin."
            return false
        }
        if password.count < 6 {
            errorMessage = "Şifre en az 6 karakter olmalı."
            return false
        }
        if password != confirmPassword {
            errorMessage = "Şifreler eşleşmiyor."
            return false
        }
        if !agreeTOS {
            errorMessage = "Devam etmek için koşulları kabul edin."
            return false
        }
        errorMessage = nil
        return true
    }
}
