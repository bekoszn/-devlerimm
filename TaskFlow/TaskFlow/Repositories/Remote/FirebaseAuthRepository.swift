import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: Error, LocalizedError {
    case notAuthenticated, invalidEmail, emailAlreadyInUse, weakPassword, userNotFound, wrongPassword, networkError, requiresRecentLogin, underlying(Error)
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Giriş yapılmadı."
        case .invalidEmail: return "Geçerli bir e-posta girin."
        case .emailAlreadyInUse: return "Bu e-posta zaten kayıtlı."
        case .weakPassword: return "Şifre çok zayıf."
        case .userNotFound: return "Kullanıcı bulunamadı."
        case .wrongPassword: return "E-posta veya şifre hatalı."
        case .networkError: return "Ağ hatası."
        case .requiresRecentLogin: return "Tekrar giriş yapmanız gerekiyor."
        case .underlying(let e): return e.localizedDescription
        }
    }
}

final class FirebaseAuthRepository {
    init() {}

    func signUp(fullName: String, email: String, password: String) async throws {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let change = result.user.createProfileChangeRequest()
        change.displayName = fullName
        try await withCheckedThrowingContinuation { $0.resume(with: .init { try change.commitChanges() }) }
        try await Firestore.firestore().collection("users").document(result.user.uid).setData([
            "uid": result.user.uid,
            "fullName": fullName,
            "email": email,
            "role": "worker",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        try? await result.user.sendEmailVerification()
    }

    func signIn(email: String, password: String) async throws {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        do { _ = try await Auth.auth().signIn(withEmail: email, password: password) }
        catch { throw map(error) }
    }

    func signOut() throws { try Auth.auth().signOut() }

    func currentUserID() -> String? { Auth.auth().currentUser?.uid }
    func currentUserEmail() -> String? { Auth.auth().currentUser?.email }

    func sendPasswordReset(email: String) async throws {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().sendPasswordReset(withEmail: email) { err in
                if let err { cont.resume(throwing: err) } else { cont.resume() }
            }
        }
    }

    // Firestore: users/{uid}.role -> "admin"|"worker"
    func fetchRole() async throws -> Role {
        guard let uid = Auth.auth().currentUser?.uid else { throw AuthError.notAuthenticated }
        let snap = try await Firestore.firestore().collection("users").document(uid).getDocument()
        let roleStr = (snap.data()?["role"] as? String) ?? "worker"
        return Role(rawValue: roleStr) ?? .worker
    }

    private func map(_ error: Error) -> AuthError {
        let ns = error as NSError
        let code = AuthErrorCode(_bridgedNSError: ns)?.code
        switch code {
        case .invalidEmail: return .invalidEmail
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .weakPassword: return .weakPassword
        case .userNotFound: return .userNotFound
        case .wrongPassword: return .wrongPassword
        case .networkError: return .networkError
        case .requiresRecentLogin: return .requiresRecentLogin
        default: return .underlying(error)
        }
    }
}
