//
//  ContentView.swift
//  MasterListApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var vm = TaskListViewModel()

    @State private var showAddSheet = false
    @State private var themeColor: Color = .blue
    @State private var useAltLayout = false // Challenge: alternatif görünüm (ScrollView + LazyVStack)

    private let themePalette: [Color] = [.blue, .purple, .indigo, .teal, .mint, .orange, .pink, .red, .green]

    var body: some View {
        NavigationStack {
            Group {
                if useAltLayout {
                    // Challenge: Alternatif görünüm (ScrollView + LazyVStack)
                    ScrollView {
                        LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                            Section(header: SectionHeader(title: "Tamamlanacaklar", color: themeColor)) {
                                ForEach(pendingItems) { item in
                                    AltRow(item: item, theme: themeColor) {
                                        vm.toggleDone(item)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) { deleteItems([item]) } label: { Label("Sil", systemImage: "trash") }
                                        Button { vm.toggleDone(item) } label: { Label("Tamamla", systemImage: "checkmark.circle") }
                                    }
                                }
                            }
                            Section(header: SectionHeader(title: "Tamamlananlar", color: themeColor.opacity(0.8))) {
                                ForEach(doneItems) { item in
                                    AltRow(item: item, theme: themeColor) {
                                        vm.toggleDone(item)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) { deleteItems([item]) } label: { Label("Sil", systemImage: "trash") }
                                        Button { vm.toggleDone(item) } label: { Label("Geri Al", systemImage: "arrow.uturn.backward.circle") }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Ana görünüm: List + Sections
                    List {
                        Section("Tamamlanacaklar") {
                            ForEach(pendingItems) { item in
                                NavigationLink(value: item) {
                                    Row(item: item, theme: themeColor)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { deleteItems([item]) } label: { Label("Sil", systemImage: "trash") }
                                    Button { vm.toggleDone(item) } label: { Label("Tamamla", systemImage: "checkmark.circle") }
                                }
                            }
                            .onDelete { offsets in vm.delete(at: offsets, inDoneSection: false) }
                        }

                        Section("Tamamlananlar") {
                            ForEach(doneItems) { item in
                                NavigationLink(value: item) {
                                    Row(item: item, theme: themeColor)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { deleteItems([item]) } label: { Label("Sil", systemImage: "trash") }
                                    Button { vm.toggleDone(item) } label: { Label("Geri Al", systemImage: "arrow.uturn.backward.circle") }
                                }
                            }
                            .onDelete { offsets in vm.delete(at: offsets, inDoneSection: true) }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("MasterListApp")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Görünüm", selection: $useAltLayout) {
                        Text("List").tag(false)
                        Text("LazyVStack").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Label("Ekle", systemImage: "plus.circle.fill")
                    }
                }
            }
            .tint(themeColor)
            .onAppear {
                // Challenge: onAppear ile rastgele tema
                if let newTheme = themePalette.randomElement() {
                    themeColor = newTheme
                }
            }
            .navigationDestination(for: TaskItem.self) { item in
                DetailView(item: item, theme: themeColor)
            }
            .sheet(isPresented: $showAddSheet) {
                AddItemSheet { title, detail in
                    vm.addItem(title: title, detail: detail)
                }
            }
        }
    }

    private var pendingItems: [TaskItem] { vm.items.filter { !$0.isDone } }
    private var doneItems: [TaskItem] { vm.items.filter { $0.isDone } }

    private func deleteItems(_ itemsToDelete: [TaskItem]) {
        let ids = Set(itemsToDelete.map { $0.id })
        vm.items.removeAll { ids.contains($0.id) }
    }
}

// MARK: - Row Views
struct Row: View {
    let item: TaskItem
    let theme: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .imageScale(.large)
                .foregroundStyle(theme)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.isDone ? "tamamlandı" : "tamamlanacak")")
    }
}

struct AltRow: View {
    let item: TaskItem
    let theme: Color
    var onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .tint(theme)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SectionHeader: View {
    let title: String
    let color: Color
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(color.opacity(0.08))
            Text(title)
                .font(.subheadline).bold()
                .padding(.horizontal)
                .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}

// MARK: - Detail
struct DetailView: View {
    let item: TaskItem
    let theme: Color
    @State private var symbolName: String = ""

    private let candidates: [String] = [
        "sparkles", "star", "bolt", "flame", "heart", "leaf", "book", "paperplane", "scribble", "clock", "graduationcap", "pencil", "folder"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: symbolName)
                .font(.system(size: 72, weight: .regular))
                .padding(8)
                .foregroundStyle(theme)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(item.title)
                    .font(.title2).bold()
                Text(item.detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            symbolName = candidates.randomElement() ?? "sparkles"
        }
    }
}

// MARK: - Add Sheet
struct AddItemSheet: View {
    @Environment(\ .dismiss) private var dismiss
    @State private var title: String = ""
    @State private var detail: String = ""

    var onAdd: (_ title: String, _ detail: String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("Örn: Sunum hazırlanacak", text: $title)
                }
                Section("Açıklama") {
                    TextField("Örn: Pazartesi'ye kadar slaytlar...", text: $detail, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Yeni Öğe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        onAdd(title, detail)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview {
    ContentView()
}
