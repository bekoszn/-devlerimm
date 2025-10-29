//
//  PDFPreviewView.swift
//  TaskFlow
//

import SwiftUI
import SwiftData
import PDFKit

struct PDFPreviewView: View {
    let taskID: String
    @Environment(\.modelContext) private var context
    @StateObject private var vm: PDFPreviewViewModel

    init(taskID: String) {
        self.taskID = taskID
        _vm = StateObject(wrappedValue: PDFPreviewViewModel(taskID: taskID))
    }

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

            VStack(spacing: 14) {

                // İçerik
                Group {
                    if let url = vm.fileURL, let doc = PDFDocument(url: url) {
                        PDFKitRepresentedView(document: doc)
                            .background(.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if vm.isGenerating {
                        VStack(spacing: 12) {
                            ProgressView().tint(.white)
                            Text("PDF oluşturuluyor…")
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if let err = vm.errorMessage {
                        Label(err, systemImage: "exclamationmark.octagon.fill")
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.15), lineWidth: 1))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    } else {
                        VStack(spacing: 14) {
                            EmptyStateView(
                                title: "PDF hazır değil",
                                subtitle: "Henüz bir PDF üretilmemiş."
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                // İpucu bandı
                footerHint

                // Aksiyonlar (yalnızca iki buton)
                HStack(spacing: 10) {
                    if let url = vm.fileURL {
                        ShareLink(item: url) {
                            Label("Paylaş", systemImage: "square.and.arrow.up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                    }

                    Button {
                        Task { await vm.generate(context: context) }
                    } label: {
                        HStack(spacing: 8) {
                            if vm.isGenerating { ProgressView().tint(.black) }
                            Label(vm.isGenerating ? "Oluşturuluyor…" : "PDF Oluştur",
                                  systemImage: "doc.richtext")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                    .disabled(vm.isGenerating)
                }
            }
            .padding(14)
        }
        .navigationTitle("PDF Önizleme")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.tryLoadIfExists() }
        .tint(.white)
    }

    // MARK: - Footer Hint
    @ViewBuilder
    private var footerHint: some View {
        let hasPDF = vm.fileURL != nil
        HStack(spacing: 8) {
            Image(systemName: hasPDF ? "checkmark.seal.fill" : "sparkles")
                .imageScale(.medium)
            Text(hasPDF
                 ? "PDF hazır. Paylaşabilir veya yeniden oluşturabilirsiniz."
                 : "PDF oluşturmak için aşağıdaki “PDF Oluştur” butonuna dokunun.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

/// PDFKit için UIKit köprüsü
struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdf = PDFView()
        pdf.displayMode = .singlePageContinuous
        pdf.displayDirection = .vertical
        pdf.autoScales = true
        pdf.minScaleFactor = pdf.scaleFactorForSizeToFit
        pdf.maxScaleFactor = 4.0
        pdf.backgroundColor = .clear
        pdf.document = document
        return pdf
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
