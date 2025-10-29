//
//  AuthViewModel.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 26.10.2025.
//


import SwiftUI
import FirebaseAuth
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var user: FirebaseAuth.User? = nil

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isLoading = false
        }
        Auth.auth().useAppLanguage()
    }

    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ProgressView("Yükleniyor…")
        }
    }
}
