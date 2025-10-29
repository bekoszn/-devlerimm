//
//  TaskDetailView.swift
//  TaskFlow
//

import SwiftUI
import SwiftData
import UserNotifications
import PDFKit

struct TaskDetailView: View {
    @Environment(\.modelContext) private var context

    let taskID: String
    var goSignature: (String) -> Void = { _ in }
    var goPDF: (String) -> Void = { _ in }
    var onClose: (() -> Void)? = nil

    @StateObject private var vm: TaskDetailViewModel

    init(taskID: String,
         goSignature: @escaping (String) -> Void = { _ in },
         goPDF: @escaping (String) -> Void = { _ in },
         onClose: (() -> Void)? = nil) {
        self.taskID = taskID
        self.goSignature = goSignature
        self.goPDF = goPDF
        self.onClose = onClose
        _vm = StateObject(wrappedValue: TaskDetailViewModel(taskID: taskID))
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            Group {
                if let t = vm.task {
                    ScrollView { content(for: t) }
                } else {
                    loadingView
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        Task { await scheduleSLAIfPossible() }
                    } label: {
                        Label("SLA Bildirimlerini Planla", systemImage: "bell.badge")
                    }
                    Button(role: .destructive) {
                        Task { await cancelSLA() }
                    } label: {
                        Label("SLA Bildirimlerini İptal Et", systemImage: "bell.slash")
                    }
                } label: { Image(systemName: "bell") }
            }
            if let onClose {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onClose() } label: { Image(systemName: "xmark.circle.fill") }
                        .tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
        .task { await vm.load(context: context) }
    }

    // MARK: - Subviews

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 0.08, green: 0.10, blue: 0.14),
                Color(red: 0.11, green: 0.13, blue: 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func content(for t: WorkItem) -> some View {
        VStack(spacing: 16) {
            headerCard(t)
            timeCard(t)
            if t.signatureName != nil || t.signatureAt != nil { signatureCard(t) }
            StatusStepperView(
                status: t.status,
                onPrev: {
                    guard !vm.isBusy else { return }
                    Task { await vm.rewind(context: context) }
                },
                onNext: {
                    guard !vm.isBusy else { return }
                    Task { await vm.advance(context: context) }
                }
            )
            actionButtons(t)
            if let err = vm.errorMessage { errorBanner(err) }
        }
        .padding(16)
    }

    private func headerCard(_ t: WorkItem) -> some View {
        CardBlock {
            VStack(alignment: .leading, spacing: 8) {
                Text(t.title).font(.title2).bold()
                Text(t.detail.isEmpty ? "Açıklama yok" : t.detail)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(t.status.displayTitle, systemImage: "arrow.right.circle")
                    if let name = t.assigneeName, !name.isEmpty {
                        Label(name, systemImage: "person")
                    }
                    if let loc = t.locationName, !loc.isEmpty {
                        Label(loc, systemImage: "mappin.circle")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func timeCard(_ t: WorkItem) -> some View {
        CardBlock {
            HStack(alignment: .center) {
                // Projendeki var olan rozet bileşeni
                SLABadgeView(sla: SLA(deadline: t.deadline), showText: true)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Güncelleme: \(t.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Oluşturma: \(t.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func signatureCard(_ t: WorkItem) -> some View {
        CardBlock {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "signature").imageScale(.medium)
                    Text("İmza").font(.headline)
                    Spacer()
                    if let d = t.signatureAt {
                        Text(d.formatted(date: .abbreviated, time: .shortened))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if let name = t.signatureName, !name.isEmpty {
                    Text("İmzalayan: \(name)").font(.subheadline)
                }

                if let img = SignatureStore.image(for: t.id) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .padding(6)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.12), lineWidth: 1))
                } else {
                    Text("İmza görseli yok.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func actionButtons(_ t: WorkItem) -> some View {
        HStack(spacing: 12) {
            Button {
                guard !vm.isBusy else { return }
                goSignature(t.id)
            } label: {
                Text("İmzala")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .foregroundStyle(.black)
            }
            .disabled(vm.isBusy)

            Button {
                guard !vm.isBusy else { return }
                goPDF(t.id)
            } label: {
                Text("PDF Önizleme")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.12), lineWidth: 1))
                    .foregroundStyle(.white)
            }
            .disabled(vm.isBusy)
        }
    }

    private func errorBanner(_ err: String) -> some View {
        Label(err, systemImage: "exclamationmark.octagon.fill")
            .foregroundStyle(.red)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView().tint(.white)
            Text("Yükleniyor…").foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Local SLA Notifications

    private func scheduleSLAIfPossible() async {
        guard let t = vm.task, let deadline = t.deadline else {
            vm.errorMessage = "Planlanacak deadline bulunamadı."
            return
        }
        do {
            let granted = try await requestNotificationAuth()
            guard granted else {
                vm.errorMessage = "Bildirim izni gerekli."
                return
            }
            try await scheduleSLA(for: t.id, title: t.title, deadline: deadline)
        } catch {
            vm.errorMessage = error.localizedDescription
        }
    }

    private func cancelSLA() async {
        guard let id = vm.task?.id else { return }
        let ids = ["warn","critical","deadline"].map { "task.\(id).sla.\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func requestNotificationAuth() async throws -> Bool {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Bool, Error>) in
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
                    if let err { cont.resume(throwing: err) }
                    else { cont.resume(returning: granted) }
                }
        }
    }

    private func scheduleSLA(for taskId: String, title: String, deadline: Date) async throws {
        let center = UNUserNotificationCenter.current()
        func makeId(_ tag: String) -> String { "task.\(taskId).sla.\(tag)" }

        let now = Date()
        let warnDate: Date = deadline.addingTimeInterval(-24*3600)
        let criticalDate: Date = deadline.addingTimeInterval(-3600)

        var requests: [UNNotificationRequest] = []

        if warnDate > now {
            requests.append(makeRequest(id: makeId("warn"),
                                        title: "SLA Uyarı",
                                        body: "“\(title)” için 24 saatten az kaldı.",
                                        fireAt: warnDate))
        }
        if criticalDate > now {
            requests.append(makeRequest(id: makeId("critical"),
                                        title: "SLA Kritik",
                                        body: "“\(title)” için 1 saatten az kaldı!",
                                        fireAt: criticalDate))
        }
        if deadline > now {
            requests.append(makeRequest(id: makeId("deadline"),
                                        title: "SLA Süresi Doldu",
                                        body: "“\(title)” görevinin süre sonu geldi.",
                                        fireAt: deadline))
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for r in requests {
                group.addTask { try await add(r, to: center) }
            }
            try await group.waitForAll()
        }
    }

    private func add(_ request: UNNotificationRequest, to center: UNUserNotificationCenter) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }

    private func makeRequest(id: String, title: String, body: String, fireAt: Date) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireAt)
        comps.timeZone = .current
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
