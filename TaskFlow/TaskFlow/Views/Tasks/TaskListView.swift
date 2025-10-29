//
//  TaskListView.swift
//  TaskFlow
//

import SwiftUI
import SwiftData
import Combine

struct TaskListView: View {
    @Environment(\.modelContext) private var context

    // Navigation callbacks (Router yok)
    var goCreate: () -> Void
    var goDetail: (String) -> Void
    var goSettings: () -> Void

    @StateObject private var vm = TaskListViewModel()

    @State private var sort: SortOption = .updatedDesc
    @State private var layout: Layout = .auto

    // App öne gelince otomatik yenileme
    @Environment(\.scenePhase) private var scenePhase

    private var filteredSorted: [WorkItem] {
        let base = vm.filtered
        return base.sorted { a, b in sort.areInIncreasingOrder(a, b) }
    }

    var body: some View {
        GeometryReader { geo in
            let cols = layout.columns(for: geo.size.width)
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
                        HeaderControlsView(
                            total: vm.tasks.count,
                            statusCounts: Dictionary(grouping: vm.tasks, by: \.status).mapValues(\.count),
                            statusFilter: $vm.statusFilter,
                            sort: $sort,
                            layout: $layout
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        LazyVGrid(columns: cols, spacing: 16) {
                            if filteredSorted.isEmpty {
                                EmptyStateCard().gridSpan(cols.count)
                            } else {
                                ForEach(filteredSorted, id: \.id) { item in
                                    TaskCard(
                                        item: item,
                                        onTap: { goDetail(item.id) },
                                        onAdvance: { Task { await vm.quickAdvance(item, context: context) } },
                                        onDelete:  { Task { await vm.quickDelete(item, context: context) } },
                                        showDelete: vm.isAdmin // 👈 sadece admin görür
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .refreshable { await vm.refresh(context: context) }

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
        }
        .navigationTitle("Görevler")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { goSettings() } label: { Image(systemName: "gearshape.fill") }
            }
            // 👇 “+” sadece admin ise görünsün
            if vm.isAdmin {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { goCreate() } label: { Image(systemName: "plus.circle.fill") }
                        .disabled(vm.isBusy)
                }
            }
        }
        .tint(.white)
        .searchable(text: $vm.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Başlık, kişi, konum, detay…")

        // İlk yükleme
        .task {
            await vm.resolveAdmin()
            await vm.refresh(context: context)
        }

        // Her görünüşte yenile
        .onAppear {
            Task { await vm.refresh(context: context) }
        }

        // Uygulama tekrar öne gelince yenile
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await vm.refresh(context: context) }
            }
        }
    }
}

// MARK: - Layout

private enum Layout: String, CaseIterable {
    case auto, one, two
    func columns(for width: CGFloat) -> [GridItem] {
        switch self {
        case .one:  return [GridItem(.flexible(), spacing: 16)]
        case .two:  return [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
        case .auto: return width > 920 ? [GridItem(.flexible()), GridItem(.flexible())]
                                       : [GridItem(.flexible())]
        }
    }
}

// MARK: - Header / Filters

private struct HeaderControlsView: View {
    let total: Int
    let statusCounts: [TaskStatus: Int]
    @Binding var statusFilter: TaskStatus?
    @Binding var sort: SortOption
    @Binding var layout: Layout

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Genel Bakış").font(.title2.weight(.bold)).foregroundStyle(.white)
                    Text("Toplam \(total) görev").font(.subheadline).foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Menu {
                    Picker("Sırala", selection: $sort) {
                        ForEach(SortOption.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                } label: {
                    Label(sort.title, systemImage: "arrow.up.arrow.down.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    StatusFilterChip(title: "Hepsi",
                                     count: total,
                                     color: .white.opacity(0.3),
                                     isSelected: statusFilter == nil) { statusFilter = nil }

                    ForEach(TaskStatus.allCases, id: \.self) { s in
                        StatusFilterChip(title: s.rawValue,
                                         count: statusCounts[s] ?? 0,
                                         color: s.tintColor,
                                         isSelected: statusFilter == s) { statusFilter = s }
                    }

                    Divider().frame(height: 20).overlay(Color.white.opacity(0.3))

                    Menu {
                        Picker("Görünüm", selection: $layout) {
                            Text("Otomatik").tag(Layout.auto)
                            Text("Tek sütun").tag(Layout.one)
                            Text("İki sütun").tag(Layout.two)
                        }
                    } label: {
                        Label("Görünüm", systemImage: "rectangle.split.2x1.fill")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

private struct StatusFilterChip: View {
    var title: String
    var count: Int
    var color: Color
    var isSelected: Bool
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Circle().fill(color.opacity(0.9)).frame(width: 8, height: 8)
                Text(title)
                Text("\(count)").font(.caption2)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.white.opacity(0.18), in: Capsule())
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(isSelected ? color.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card

private struct TaskCard: View {
    let item: WorkItem
    var onTap: () -> Void
    var onAdvance: () -> Void
    var onDelete: () -> Void
    var showDelete: Bool

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top bar: status + actions
                HStack {
                    StatusBadge(status: item.status)
                    Spacer()
                    HStack(spacing: 6) {
                        if canAdvance(item.status) {
                            RoundIconButton(system: "chevron.right.circle.fill", action: onAdvance)
                        }
                        if showDelete {
                            RoundIconButton(system: "trash.fill", role: .destructive, action: onDelete)
                        }
                    }
                }

                Text(item.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                if !item.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(item.detail)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }

                MetaRow(item: item)
            }
            .padding(14)
            .background(
                ZStack {
                    LinearGradient(colors: item.status.gradientColors,
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .opacity(0.20)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(item.status.tintColor.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: item.status.tintColor.opacity(0.15), radius: 8, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                UIPasteboard.general.string = item.title
            } label: { Label("Başlığı Kopyala", systemImage: "doc.on.doc") }

            if let ass = item.assigneeName, !ass.isEmpty {
                Button { UIPasteboard.general.string = ass } label: {
                    Label("Atananı Kopyala", systemImage: "person")
                }
            }
            if let loc = item.locationName, !loc.isEmpty {
                Button { UIPasteboard.general.string = loc } label: {
                    Label("Konumu Kopyala", systemImage: "mappin.and.ellipse")
                }
            }
        }
    }

    private func canAdvance(_ s: TaskStatus) -> Bool { s != .bitti }
}

private struct StatusBadge: View {
    let status: TaskStatus
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(status.tintColor).frame(width: 8, height: 8)
            Text(status.rawValue).font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(status.tintColor.opacity(0.18), in: Capsule())
        .overlay(Capsule().stroke(status.tintColor.opacity(0.4), lineWidth: 1))
        .foregroundStyle(.white)
    }
}

private struct MetaRow: View {
    let item: WorkItem
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                if let a = item.assigneeName, !a.isEmpty {
                    IconPill(system: "person.crop.circle", text: a)
                }
                if let l = item.locationName, !l.isEmpty {
                    IconPill(system: "mappin.circle", text: l)
                }
                if let d = item.deadline {
                    IconPill(system: "calendar.badge.clock",
                             text: d.formatted(date: .abbreviated, time: .shortened))
                        .overlay(
                            Capsule().stroke(slaColor(deadline: d).opacity(0.5), lineWidth: 1)
                        )
                }
                Spacer()
            }
            HStack {
                Text("Oluşturma: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2).foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("Güncellenme: \(item.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2).foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private func slaColor(deadline: Date) -> Color {
        let now = Date()
        if deadline < now { return .purple } // overdue
        let remain = deadline.timeIntervalSince(now)
        let hour: TimeInterval = 3600
        if remain <= hour { return .red }         // critical
        if remain <= 24 * hour { return .orange } // warning
        return .green
    }
}

private struct RoundIconButton: View {
    var system: String
    var role: ButtonRole? = nil
    var action: () -> Void
    var body: some View {
        Button(role: role, action: action) {
            Image(systemName: system)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
                .padding(8)
                .background(.white.opacity(0.08), in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State

private struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 28, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.9))
            Text("Görev bulunamadı").font(.headline).foregroundStyle(.white)
            Text("Filtreleri temizleyin veya aramayı değiştirin.")
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - SortOption

private enum SortOption: CaseIterable, Hashable {
    case updatedDesc, updatedAsc, titleAZ, titleZA, deadlineAsc, deadlineDesc, status

    var title: String {
        switch self {
        case .updatedDesc: return "Güncellenme (Yeni → Eski)"
        case .updatedAsc:  return "Güncellenme (Eski → Yeni)"
        case .titleAZ:     return "Başlık (A → Z)"
        case .titleZA:     return "Başlık (Z → A)"
        case .deadlineAsc: return "Bitiş (Yakın → Uzak)"
        case .deadlineDesc:return "Bitiş (Uzak → Yakın)"
        case .status:      return "Durum"
        }
    }

    func areInIncreasingOrder(_ a: WorkItem, _ b: WorkItem) -> Bool {
        switch self {
        case .updatedDesc: return a.updatedAt > b.updatedAt
        case .updatedAsc:  return a.updatedAt < b.updatedAt
        case .titleAZ:     return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        case .titleZA:     return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedDescending
        case .deadlineAsc: return (a.deadline ?? .distantFuture) < (b.deadline ?? .distantFuture)
        case .deadlineDesc:return (a.deadline ?? .distantPast)  > (b.deadline ?? .distantPast)
        case .status:      return a.status.order < b.status.order
        }
    }
}

private extension View {
    func gridSpan(_ c: Int) -> some View { self.gridCellColumns(c) }
}

// Basit IconPill
private struct IconPill: View {
    var system: String
    var text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: system)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
                .imageScale(.small)
            Text(text)
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}
