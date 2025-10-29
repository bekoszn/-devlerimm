//
//  SettingsView.swift
//  TaskFlow
//

import SwiftUI
import Combine
import UserNotifications
import UIKit

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject private var auth: AuthViewModel   // 🔑 AuthGate ile aynı instance
    var onClose: (() -> Void)? = nil

    // foreground dönüşlerinde bildirim izin durumunu yenile
    private let willEnterForeground = NotificationCenter.default.publisher(
        for: UIApplication.willEnterForegroundNotification
    )

    var body: some View {
        ZStack {
            // Modern koyu arkaplan
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.08, green: 0.10, blue: 0.14),
                    Color(red: 0.11, green: 0.13, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ayarlar")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                        Text("Bildirim tercihlerini yönet")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Bildirim durumu kartı
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: vm.notificationsAllowed ? "bell.badge.fill" : "bell.slash.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title2.bold())
                                .foregroundStyle(vm.notificationsAllowed ? .green : .red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bildirim İzni")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(vm.notificationsAllowed ? "Etkin" : "Kapalı")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                        }

                        HStack(spacing: 10) {
                            Button {
                                Task { await vm.requestNotifications() }
                            } label: {
                                HStack {
                                    Image(systemName: "bell.badge")
                                    Text("Bildirim izni iste")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.black)
                            }

                            Button { vm.openSystemSettings() } label: {
                                HStack {
                                    Image(systemName: "gearshape")
                                    Text("Sistem Ayarları")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.12),
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.12), lineWidth: 1))
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                    .padding(.horizontal, 16)

                    // Hata mesajı (varsa)
                    if let err = vm.errorMessage {
                        Label(err, systemImage: "exclamationmark.octagon.fill")
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                            .padding(.horizontal, 16)
                    }

                    // --- ÇIKIŞ YAP KARTI ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hesap")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Oturumunuzu sonlandırın")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                        }

                        Button(role: .destructive) {
                            auth.signOut()   // 🔴 Sadece bu yeterli. AuthGate LoginView'a döndürecek.
                        } label: {
                            HStack {
                                Image(systemName: "power")
                                Text("Çıkış Yap")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.18),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.35), lineWidth: 1))
                            .foregroundStyle(.red)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.12), lineWidth: 1))
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
        }
        .toolbar {
            if let onClose {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onClose() } label: {
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                    .tint(.white)
                }
            }
        }
        .tint(.white)
        .task { await vm.refreshNotificationStatus() }
        .onReceive(willEnterForeground) { _ in
            Task { await vm.refreshNotificationStatus() }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
