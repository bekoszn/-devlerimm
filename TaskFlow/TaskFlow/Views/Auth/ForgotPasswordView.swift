//
//  ForgotPasswordView.swift
//  TaskFlow
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ForgotPasswordViewModel()

    var body: some View {
        ZStack {
            // Modern koyu arkaplan (tüm sayfalarda hedeflediğin stile uyumlu)
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

            VStack(spacing: 22) {
                // Başlık blok
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation.open")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Şifremi Unuttum")
                        .font(.title).bold()
                        .foregroundStyle(.white)

                    Text("Hesabınıza bağlı e-postayı girin; size sıfırlama bağlantısı gönderelim.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                }
                .padding(.top, 32)

                // Kart
                VStack(spacing: 16) {
                    AuthField(title: "E-posta", text: $vm.email, keyboard: .emailAddress)

                    if let info = vm.infoMessage {
                        Label(info, systemImage: "checkmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let err = vm.errorMessage {
                        Label(err, systemImage: "exclamationmark.octagon.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button(action: { Task { await vm.sendReset() } }) {
                        HStack(spacing: 8) {
                            if vm.isLoading { ProgressView().tint(.black) }
                            Text(vm.isLoading ? "Gönderiliyor…" : "Sıfırlama Bağlantısı Gönder")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(.black)
                    }
                    .disabled(vm.isLoading)

                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Geri Dön")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(.white)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 28, y: 12)
                .padding(.horizontal, 20)

                Spacer(minLength: 24)
            }
            .tint(.white) // toggles/links beyaz aksan
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
