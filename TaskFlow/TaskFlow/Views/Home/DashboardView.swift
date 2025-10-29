//
//  DashboardView.swift
//  TaskFlow
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = DashboardViewModel()

    // Router yok; üstten geçilecek aksiyonlar
    var goTaskList: () -> Void = {}
    var goCreateTask: () -> Void = {}
    var goSettings: () -> Void = {}
    var onSignOut: () -> Void = {}

    // Tehlikeli işlem onayı
    @State private var showPurgeConfirm = false

    private var columns: [GridItem] {
        let count = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: count)
    }

    var body: some View {
        ZStack {
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
                VStack(alignment: .leading, spacing: 16) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting())
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                        Text("Gösterge Paneli")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                        StatusLegend()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Özet kartlar
                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCard(title: "Toplam Görev",
                                 value: vm.isLoading ? "—" : "\(vm.taskCount)",
                                 systemIcon: "tray.full",
                                 color: .white.opacity(0.9),
                                 tint: .white)
                        .redacted(reason: vm.isLoading ? .placeholder : [])

                        StatCard(title: "Kritik",
                                 value: vm.isLoading ? "—" : "\(vm.criticalCount)",
                                 systemIcon: "exclamationmark.triangle.fill",
                                 color: .orange,
                                 tint: .orange)
                        .redacted(reason: vm.isLoading ? .placeholder : [])

                        StatCard(title: "Uyarı",
                                 value: vm.isLoading ? "—" : "\(vm.warningCount)",
                                 systemIcon: "clock.arrow.circlepath",
                                 color: .yellow,
                                 tint: .yellow)
                        .redacted(reason: vm.isLoading ? .placeholder : [])
                    }
                    .padding(.horizontal, 16)

                    // Aksiyonlar
                    VStack(spacing: 10) {
                        Button(action: goTaskList) { buttonLabel("Görev Listesi") }
                            .buttonStyle(.plain)

                        if vm.isAdmin {
                            Button(action: goCreateTask) { buttonLabel("Yeni Görev Oluştur") }
                                .buttonStyle(.plain)
                                .transition(.opacity.combined(with: .scale))
                        }

                        Button(action: goSettings) { buttonLabel("Ayarlar") }
                            .buttonStyle(.plain)

                        // 👇 Lokal temizlik kaldırıldı — yerine “Tümünü Sil (Local + Firebase)”
                        if vm.isAdmin {
                            Button {
                                showPurgeConfirm = true
                            } label: {
                                buttonLabel("Tümünü Sil (Local + Firebase)", destructive: true)
                            }
                            .buttonStyle(.plain)
                            .disabled(vm.isLoading || vm.taskCount == 0)
                            .alert("Tüm görevler silinsin mi?",
                                   isPresented: $showPurgeConfirm) {
                                Button("İptal", role: .cancel) {}
                                Button("Hepsini Sil", role: .destructive) {
                                    Task { await vm.purgeAll(context: context) }
                                }
                            } message: {
                                Text("Bu işlem geri alınamaz. Hem cihazdaki SwiftData, hem de Firestore’daki TÜM görevler kalıcı olarak silinir.")
                            }
                        }

                        // İsteğe bağlı: Dashboard içinden çıkış
                        Button(role: .destructive, action: onSignOut) {
                            buttonLabel("Çıkış Yap", destructive: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 12)
            }
            .refreshable { await vm.refreshNow(context: context) }

            if let err = vm.errorMessage {
                VStack {
                    Label(err, systemImage: "exclamationmark.octagon.fill")
                        .padding(12)
                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                    Spacer()
                }
                .allowsHitTesting(false)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle("TaskFlow")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.initialLoad(context: context) }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(.white)
    }

    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Günaydın 👋"
        case 12..<18: return "İyi günler 👋"
        case 18..<23: return "İyi akşamlar 👋"
        default:      return "Merhaba 👋"
        }
    }

    private func buttonLabel(_ title: String, destructive: Bool = false) -> some View {
        Text(title).bold()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(destructive ? Color.red : Color.white)
            .foregroundStyle(destructive ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.18), radius: 10, y: 6)
    }
}

// StatusLegend, LegendDot, StatCard — aynı
private struct StatusLegend: View {
    var body: some View {
        HStack(spacing: 10) {
            LegendDot(color: .orange)
            Text("Kritik / Gecikmiş").font(.caption).foregroundStyle(.white.opacity(0.9))
            LegendDot(color: .yellow)
            Text("Uyarı").font(.caption).foregroundStyle(.white.opacity(0.9))
        }
        .padding(10)
        .background(.white.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
    }
}

private struct LegendDot: View {
    let color: Color
    var body: some View { Circle().fill(color).frame(width: 8, height: 8) }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemIcon: String
    let color: Color
    let tint: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 16, y: 10)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: systemIcon)
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(tint)
                    Spacer()
                }
                Text(value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(16)
        }
        .frame(height: 120)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)")
    }
}
