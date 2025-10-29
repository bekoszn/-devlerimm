//
//  RegisterView.swift
//  TaskFlow
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RegisterViewModel()

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
                VStack(spacing: 22) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Kayıt Ol")
                            .font(.title).bold()
                            .foregroundStyle(.white)

                        Text("Yeni bir TaskFlow hesabı oluşturun.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 16) {
                        AuthField(title: "Ad Soyad", text: $vm.fullName)
                        AuthField(title: "E-posta", text: $vm.email, keyboard: .emailAddress)
                        AuthField(title: "Şifre", text: $vm.password, isSecure: true)
                        AuthField(title: "Şifre (Tekrar)", text: $vm.confirmPassword, isSecure: true)

                        Toggle(isOn: $vm.agreeTOS) {
                            Text("Kullanım koşullarını ve gizlilik politikasını kabul ediyorum.")
                        }
                        .font(.footnote)
                        .tint(.white)
                        .foregroundStyle(.white)

                        if let err = vm.errorMessage {
                            Label(err, systemImage: "exclamationmark.octagon.fill")
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task { await vm.signUp() }
                        } label: {
                            HStack(spacing: 8) {
                                if vm.isLoading { ProgressView().tint(.black) }
                                Text(vm.isLoading ? "Hesap oluşturuluyor…" : "Hesap Oluştur")
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
                            Text("Zaten hesabın var mı? Giriş Yap")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.12),
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 28, y: 12)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(.white)
    }
}
