import Combine
import Foundation
import FirebaseAuth

final class SessionStore: ObservableObject {
    enum State: Hashable {
        case loading, unauthenticated, authenticated(userID: String)
    }
    @Published private(set) var state: State = .loading

    func bootstrap() {
        // İlk durum
        if let uid = Auth.auth().currentUser?.uid {
            state = .authenticated(userID: uid)
        } else {
            state = .unauthenticated
        }
        // Dinleyici
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.state = user != nil ? .authenticated(userID: user!.uid) : .unauthenticated
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        state = .unauthenticated
    }
}
