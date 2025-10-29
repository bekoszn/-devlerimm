//
//  LoginView.swift
//  TaskFlow
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    @State private var goRegister = false
    @State private var goForgot = false

    var body: some View {
        NavigationStack {
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
                    VStack(spacing: 22) {
                        // Logo / Başlık
                        VStack(spacing: 8) {
                            Image(systemName: "checklist")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 52, weight: .bold))
                                .foregroundStyle(.white)

                            Text("TaskFlow")
                                .font(.largeTitle).fontWeight(.heavy)
                                .foregroundStyle(.white)

                            Text("Görevlerinizi basit, hızlı ve akıllı yönetin.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 360)
                        }
                        .padding(.top, 40)

                        // Kart
                        VStack(spacing: 16) {
                            AuthField(title: "E-posta", text: $vm.email, isSecure: false, keyboard: .emailAddress)
                            AuthField(title: "Şifre", text: $vm.password, isSecure: true)

                            HStack {
                                Toggle(isOn: $vm.rememberMe) {
                                    Text("Beni hatırla")
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .white))
                                .tint(.white)

                                Spacer()

                                Button("Şifremi unuttum?") { goForgot = true }
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                            }

                            if let err = vm.errorMessage {
                                Label(err, systemImage: "exclamationmark.octagon.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                Task { await vm.signIn() }
                            } label: {
                                HStack(spacing: 8) {
                                    if vm.isLoading { ProgressView().tint(.black) }
                                    Text(vm.isLoading ? "Giriş yapılıyor…" : "Giriş Yap")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.black)
                            }
                            .disabled(vm.isLoading)
                            .padding(.top, 4)

                            // Divider + register
                            HStack {
                                Rectangle().frame(height: 1).foregroundStyle(.white.opacity(0.15))
                                Text("veya").foregroundStyle(.white.opacity(0.8))
                                Rectangle().frame(height: 1).foregroundStyle(.white.opacity(0.15))
                            }
                            .padding(.vertical, 4)

                            Button {
                                goRegister = true
                            } label: {
                                Text("Hesabın yok mu? Kayıt Ol")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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
            .navigationDestination(isPresented: $goRegister) { RegisterView() }
            .navigationDestination(isPresented: $goForgot) { ForgotPasswordView() }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .tint(.white)
    }
}
