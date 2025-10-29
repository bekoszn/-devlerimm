//
//  SettingsViewModel.swift
//  TaskFlow
//

import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsAllowed: Bool = false
    @Published var errorMessage: String? = nil

    // Bildirim izin durumunu yenile
    func refreshNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsAllowed = (settings.authorizationStatus == .authorized ||
                                settings.authorizationStatus == .provisional ||
                                settings.authorizationStatus == .ephemeral)
    }

    // İzin iste
    func requestNotifications() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if !granted {
                errorMessage = "Bildirim izni verilmedi. Ayarlardan değiştirebilirsin."
            } else {
                errorMessage = nil
            }
            await refreshNotificationStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Sistem Ayarları’nı aç
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
