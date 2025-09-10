//
//  ContentView.swift
//  EventApp
//
//  Created by Berke Özgüder on 10.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = EventListViewModel()
    @State private var showAddSheet = false

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.events) { event in
                    NavigationLink(value: event) {
                        EventRow(event: event, dateFormatter: dateFormatter)
                    }
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Etkinlikler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Label("Ekle", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddEventSheet { title, date, type, hasReminder in
                    vm.add(title: title, date: date, type: type, hasReminder: hasReminder)
                }
            }
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event) { action in
                    switch action {
                    case .delete:
                        vm.delete(event)
                    case .toggleReminder:
                        vm.toggleReminder(for: event)
                    }
                }
            }
        }
    }
}

// MARK: - Row
struct EventRow: View {
    let event: Event
    let dateFormatter: DateFormatter

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.type.icon)
                .imageScale(.large)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text(dateFormatter.string(from: event.date))
                    Text("•")
                    Text(event.type.rawValue)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if event.hasReminder {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Hatırlatıcı açık")
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(event.type.rawValue), \(event.hasReminder ? "hatırlatıcı açık" : "hatırlatıcı kapalı")")
    }
}

// MARK: - Add Sheet (Form)
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var type: EventType = .other
    @State private var hasReminder: Bool = false

    var onAdd: (_ title: String, _ date: Date, _ type: EventType, _ hasReminder: Bool) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Etkinlik") {
                    TextField("Etkinlik adı", text: $title)
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Tür", selection: $type) {
                        ForEach(EventType.allCases) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                    Toggle("Hatırlatıcı", isOn: $hasReminder)
                }
            }
            .navigationTitle("Yeni Etkinlik")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        onAdd(title, date, type, hasReminder)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Detail
struct EventDetailView: View {
    enum Action { case delete, toggleReminder }

    let event: Event
    var onAction: (Action) -> Void
    @Environment(\.dismiss) private var dismiss

    private let df: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateStyle = .full
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: event.type.icon)
                .font(.system(size: 64))
                .padding(4)

            VStack(spacing: 8) {
                Text(event.title)
                    .font(.title2).bold()
                Text(df.string(from: event.date))
                    .foregroundStyle(.secondary)
                Text(event.type.rawValue)
                    .font(.subheadline)
                    .padding(.top, 2)
            }
            .multilineTextAlignment(.center)

            Toggle(isOn: .init(
                get: { event.hasReminder },
                set: { _ in onAction(.toggleReminder) }
            )) {
                Label("Hatırlatıcı", systemImage: "bell")
            }
            .padding(.horizontal)

            Spacer()

            Button(role: .destructive) {
                onAction(.delete)
                dismiss()
            } label: {
                Label("Etkinliği Sil", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview { ContentView() }
