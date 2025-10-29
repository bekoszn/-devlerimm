//
//  CreateTaskView.swift
//  TaskFlow
//

import SwiftUI
import SwiftData

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject private var vm = CreateTaskViewModel()

    var onDone: (() -> Void)? = nil

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
                        Text("Yeni Görev")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                        Text("Başlık, açıklama ve isteğe bağlı alanlarla yeni görev oluştur.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Kart (Form)
                    VStack(spacing: 14) {
                        field(title: "Başlık") {
                            TextField("Başlık", text: $vm.title)
                                .submitLabel(.done)
                                .textInputAutocapitalization(.sentences)
                        }

                        field(title: "Açıklama") {
                            TextField("Açıklama", text: $vm.detail, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        field(title: "Atanan (İsim)") {
                            TextField("Ad Soyad", text: $vm.assigneeName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                        }

                        field(title: "Konum") {
                            TextField("Konum", text: $vm.locationName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                        }

                        field(title: "Bitiş") {
                            DatePicker("",
                                       selection: $vm.deadline,
                                       displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }

                        if let err = vm.errorMessage {
                            Label(err, systemImage: "exclamationmark.octagon.fill")
                                .foregroundStyle(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                        }

                        Button {
                            Task {
                                await vm.save(context: context)
                                if vm.errorMessage == nil {
                                    if let onDone { onDone() } else { dismiss() }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if vm.isSaving { ProgressView().tint(.black) }
                                Text(vm.isSaving ? "Kaydediliyor…" : "Kaydet")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(vm.canSave ? .white : .white.opacity(0.4),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(.black)
                        }
                        .disabled(!vm.canSave || vm.isSaving)
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
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
    }

    // MARK: - Field Wrapper
    @ViewBuilder
    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white.opacity(0.06),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.10), lineWidth: 1))
                .foregroundStyle(.white)
        }
    }
}
