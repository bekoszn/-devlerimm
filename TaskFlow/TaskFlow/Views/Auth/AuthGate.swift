//
//  AuthGate.swift
//  TaskFlow
//

import SwiftUI
import SwiftData
import FirebaseAuth
import Combine

struct AuthGate: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.modelContext) private var modelContext

    // Realtime Firestore → SwiftData senk
    @State private var remoteSync: FirestoreRemoteSync?

    // Bildirim izni isteği vs. (opsiyonel)
    @State private var didBootstrap = false
    @State private var notificationService = NotificationService()

    var body: some View {
        Group {
            if auth.isLoading {
                SplashView()
            } else if auth.user != nil {
                RootNav() // ⬅️ NavStack burada
            } else {
                LoginView()
            }
        }
        .task {
            // Realtime senk (bir kere başlat)
            guard remoteSync == nil else { return }
            let sync = FirestoreRemoteSync()
            sync.start(context: modelContext)
            remoteSync = sync

            // (Opsiyonel) Bildirim izni & ilk çekme gibi işler
            if !didBootstrap {
                didBootstrap = true
                _ = try? await notificationService.requestAuthorization()
            }
        }
    }
}

// MARK: - Navigation Stack (giriş yapılmışken)
private struct RootNav: View {
    @EnvironmentObject private var auth: AuthViewModel
    @State private var path: [Screen] = [.dashboard]

    var body: some View {
        NavigationStack(path: $path) {
            // Kök ekran
            DashboardView(
                goTaskList:   { path.append(.taskList) },
                goCreateTask: { path.append(.createTask) },
                goSettings:   { path.append(.settings) },
                onSignOut:    { auth.signOut() }   // çıkış → AuthGate LoginView gösterecek
            )
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .dashboard:
                    DashboardView(
                        goTaskList:   { path.append(.taskList) },
                        goCreateTask: { path.append(.createTask) },
                        goSettings:   { path.append(.settings) },
                        onSignOut:    { auth.signOut() }
                    )

                case .taskList:
                    TaskListView(
                        goCreate: { path.append(.createTask) },
                        goDetail: { id in path.append(.taskDetail(id: id)) },
                        goSettings: { path.append(.settings) }
                    )

                case .createTask:
                    CreateTaskView(onDone: { _ = path.popLast() })

                case .taskDetail(let id):
                    TaskDetailView(
                        taskID: id,
                        goSignature: { taskID in path.append(.signature(id: taskID)) },
                        goPDF: { taskID in path.append(.pdfPreview(id: taskID)) },
                        onClose: { _ = path.popLast() }
                    )

                case .signature(let id):
                    SignaturePadView(taskID: id)

                case .pdfPreview(let id):
                    PDFPreviewView(taskID: id)

                case .settings:
                    SettingsView(onClose: { _ = path.popLast() })
                }
            }
        }
    }
}
