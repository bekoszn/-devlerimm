//
//  AuthorizedShell.swift
//  TaskFlow
//

import SwiftUI
import SwiftData

/// Tüm oturum-açık akış tek NavigationStack içinde.
struct AuthorizedShell: View {
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var path: [Screen] = [.dashboard]

    // (opsiyonel) senin servislerin
    @StateObject private var session = SessionStore()
    @State private var syncService: SyncService?
    @State private var notificationService = NotificationService()
    @State private var didBootstrap = false

    var body: some View {
        NavigationStack(path: $path) {
            DashboardView(
                goTaskList:   { path.append(.taskList) },
                goCreateTask: { path.append(.createTask) },
                goSettings:   { path.append(.settings) },
                onSignOut:    { auth.signOut() }
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
                    PDFPreviewView(taskID: id)   // sende zaten varsa aynen çalışır
                case .settings:
                    SettingsView(onClose: { _ = path.popLast() })
                }
            }
        }
        .task {
            guard !didBootstrap else { return }
            didBootstrap = true
            session.bootstrap()
            let s = SyncService(context: modelContext); s.start(); syncService = s
            _ = try? await notificationService.requestAuthorization()
            try? await SyncManager.downloadAll(context: modelContext)
        }
    }
}
