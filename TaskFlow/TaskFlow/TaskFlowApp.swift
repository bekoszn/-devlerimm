//
//  TaskFlowApp.swift
//  TaskFlow
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftData
import UserNotifications

// MARK: - UIKit AppDelegate (Firebase bootstrapping)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // Firestore offline cache
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings

        Auth.auth().useAppLanguage()
        return true
    }
}

@main
struct TaskFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var auth = AuthViewModel()   // 🔑 kökte yarat

    var body: some Scene {
        WindowGroup {
            // Kökte SADECE AuthGate; modelContainer burada veriliyor
            AuthGate()
                .environmentObject(auth)
                .modelContainer(for: [WorkItem.self], isAutosaveEnabled: true)
        }
    }
}



// MARK: - RootView (TEK NavigationStack, Router YOK)
struct RootView: View {
    // === Senin orijinal değişkenlerin ===
    @StateObject private var session = SessionStore() // mevcut yapın
    @Environment(\.modelContext) private var modelContext
    @State private var syncService: SyncService?
    @State private var notificationService = NotificationService()
    @State private var didBootstrap = false

    // === Navigation path (senin Screen enum’un) ===
    @State private var path: [Screen] = [.taskList]

    // 🔑 Auth artık environment’tan geliyor — ayrı listener tutmuyoruz
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
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
                        // SettingsView, AuthViewModel’ı environment’tan alacak
                        SettingsView(onClose: { _ = path.popLast() })

                    case .dashboard:
                        DashboardView(
                            goTaskList:   { path.append(.taskList) },
                            goCreateTask: { path.append(.createTask) },
                            goSettings:   { path.append(.settings) },
                            onSignOut:    { auth.signOut() }
                        )
                    }
                }
        }
        // === Uygulama bootstrapping: SENİN SIRANI koruyarak ===
        .task {
            guard !didBootstrap else { return }
            didBootstrap = true

            // 1) Session başlat (senin kodun)
            session.bootstrap()

            // 2) Online olunca sync (senin kodun)
            let s = SyncService(context: modelContext)
            s.start()
            syncService = s

            // 3) Bildirim izni (opsiyonel)
            _ = try? await notificationService.requestAuthorization()

            // 4) İlk açılışta bir kerelik sunucudan çek (opsiyonel)
            try? await SyncManager.downloadAll(context: modelContext)
        }
    }

    // === Ekran seçimi: Auth durumu ile anahtarlama ===
    @ViewBuilder
    private var content: some View {
        if auth.isLoading {
            SplashView()
        } else if auth.user != nil {
            // Giriş yapılmış: Dashboard köke geçsin
            DashboardView(
                goTaskList:   { path.append(.taskList) },
                goCreateTask: { path.append(.createTask) },
                goSettings:   { path.append(.settings) },
                onSignOut:    { auth.signOut() } // istersen burada da gösterebilirsin
            )
        } else {
            // Çıkış → Login
            LoginView()
                .onAppear { path = [.taskList] } // path reset (temiz başla)
        }
    }
}
