//
//  PDFPreviewViewModel.swift
//  TaskFlow
//

import Foundation
import Combine
import SwiftData

@MainActor
final class PDFPreviewViewModel: ObservableObject {
    // UI state
    @Published private(set) var fileURL: URL?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    #if DEBUG
    @Published var debugInfo: String = "-"
    #endif

    // Deps
    private let pdfService: PDFServiceProtocol
    let taskID: String

    init(taskID: String, pdfService: PDFServiceProtocol = PDFService()) {
        self.taskID = taskID
        self.pdfService = pdfService
    }

    /// Daha önce oluşturulmuş bir PDF varsa onu yükle (deterministik dosya adı).
    func tryLoadIfExists() {
        let candidate = pdfService.outputURL(forTaskId: taskID)
        #if DEBUG
        updateDebug(for: candidate, prefix: "tryLoadIfExists")
        #endif
        if FileManager.default.fileExists(atPath: candidate.path) {
            self.fileURL = candidate
        }
    }

    /// PDF oluştur ve dosya yolunu UI'a ver.
    func generate(context: ModelContext) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            // Task'ı SwiftData'dan çek
            let pred = #Predicate<WorkItem> { $0.id == taskID }
            var fd = FetchDescriptor<WorkItem>(predicate: pred)
            fd.fetchLimit = 1
            guard let task = try context.fetch(fd).first else {
                self.errorMessage = "Görev bulunamadı."
                return
            }

            let url = try pdfService.generateReport(for: task.snapshot)
            self.fileURL = url
            #if DEBUG
            updateDebug(for: url, prefix: "generate")
            #endif
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    #if DEBUG
    /// Manuel kontrol: Dosya gerçekten var mı, kaç byte?
    func refreshDebug() {
        let url = pdfService.outputURL(forTaskId: taskID)
        updateDebug(for: url, prefix: "refreshDebug")
    }

    private func updateDebug(for url: URL, prefix: String) {
        let exists = FileManager.default.fileExists(atPath: url.path)
        let sizeStr: String = {
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
            if let n = attrs?[.size] as? NSNumber { return "\(n.intValue) B" }
            return "?"
        }()
        self.debugInfo = "\(prefix):\n- path: \(url.path)\n- exists: \(exists)\n- size: \(sizeStr)"
    }
    #endif
}
