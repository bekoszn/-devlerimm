import SwiftUI
import SwiftData

struct SignaturePadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let taskID: String
    @StateObject private var vm = SignatureViewModel()

    // Canvas controller
    @StateObject private var canvasController = SignatureCanvasController()

    // Önizleme resmi
    @State private var lastPreview: UIImage? = nil

    var body: some View {
        ZStack {
            // Arka plan — koyu gradient
            LinearGradient(
                colors: [Color.black,
                         Color(red: 0.08, green: 0.10, blue: 0.14),
                         Color(red: 0.11, green: 0.13, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Sabit layout — scroll yok
            VStack(spacing: 16) {
                // Başlık
                VStack(alignment: .leading, spacing: 6) {
                    Text("İmza").font(.largeTitle).bold().foregroundStyle(.white)
                    Text("Görevi imzalamak için adınızı girin ve aşağıya imza atın.")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Kart bloğu
                VStack(spacing: 14) {
                    // İsim alanı
                    VStack(alignment: .leading, spacing: 6) {
                        Text("İmzalayan")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                        TextField("Ad Soyad", text: $vm.signerName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.10), lineWidth: 1))
                            .foregroundStyle(.white)
                    }

                    // İmza Tuvali
                    VStack(alignment: .leading, spacing: 8) {
                        Text("İmza Tuvali")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))

                        SignatureCanvas(
                            controller: canvasController,
                            lineWidth: 2.0,
                            strokeColor: .black, // koyu arkaplanda net
                            onDrawingBegan: {
                                if canvasController.isEmpty { canvasController.isEmpty = false }
                            }
                        )
                        .frame(height: 260)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1))
                        .overlay {
                            if canvasController.isEmpty && lastPreview == nil {
                                Text("Parmağınızla veya kalemle imza atın")
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .allowsHitTesting(false)
                            }
                        }

                        // Tuval altı butonlar
                        HStack(spacing: 8) {
                            Button {
                                canvasController.clear()
                                lastPreview = nil
                                vm.snapshot = nil
                            } label: {
                                Label("Temizle", systemImage: "xmark.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                            .contentShape(Rectangle())

                            Button {
                                // SENKRON preview
                                let snap = canvasController.captureSnapshot()
                                lastPreview = snap
                                vm.snapshot = snap
                            } label: {
                                Label("Önizleme", systemImage: "eye")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                            .contentShape(Rectangle())
                        }

                        // Önizleme görseli
                        if let p = lastPreview {
                            Image(uiImage: p)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .padding(6)
                                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.12), lineWidth: 1))
                        }
                    }

                    // Hata banner
                    if let err = vm.errorMessage {
                        Label(err, systemImage: "exclamationmark.octagon.fill")
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                    }

                    // Kaydet butonu
                    Button {
                        Task {
                            // SENKRON snapshot → VM’ye ver → kaydet
                            let snap = canvasController.captureSnapshot()
                            vm.snapshot = snap ?? vm.snapshot
                            await vm.signAndAttach(taskID: taskID, context: context)
                            if vm.errorMessage == nil { dismiss() }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if vm.isSigning { ProgressView().tint(.black) }
                            Text(vm.isSigning ? "Kaydediliyor…" : "İmzala ve Kaydet")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.black)
                    }
                    .contentShape(Rectangle())
                    .disabled(
                        vm.isSigning ||
                        vm.signerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        (vm.snapshot == nil && canvasController.isEmpty)
                    )
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                .padding(.horizontal, 16)

                Spacer(minLength: 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
    }
}
