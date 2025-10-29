//
//  LoginViewModel.swift
//  TaskFlow
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth = FirebaseAuthRepository()

    init() {
        if let saved = UserDefaults.standard.string(forKey: "remembered_email") {
            self.email = saved
        }
    }

    func signIn() async {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await auth.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                  password: password)
            errorMessage = nil
            if rememberMe {
                UserDefaults.standard.set(email, forKey: "remembered_email")
            } else {
                UserDefaults.standard.removeObject(forKey: "remembered_email")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validate() -> Bool {
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !e.isEmpty, !password.isEmpty else {
            errorMessage = "E-posta ve şifre zorunludur."
            return false
        }
        guard e.range(of: #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#,
                      options: [.regularExpression, .caseInsensitive]) != nil else {
            errorMessage = "Lütfen geçerli bir e-posta girin."
            return false
        }
        errorMessage = nil
        return true
    }
}
