import Foundation
import SwiftData
import UIKit
import Combine

@MainActor
final class SignatureViewModel: ObservableObject {
    @Published var signerName: String = ""
    @Published var isSigning = false
    @Published var errorMessage: String?
    @Published var snapshot: UIImage?
    @Published var canvasEmpty: Bool = true  

    /// Kaydetme uygunluğu: yalnızca isim + görsel şartı
    var canSign: Bool {
        let nameOK = !signerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImage = snapshot != nil
        return nameOK && hasImage
    }

    /// Tuvalden güncelleme için yardımcı (opsiyonel kullanım)
    func updateSnapshot(image: UIImage?, isEmpty: Bool) {
        self.snapshot = image
        self.canvasEmpty = isEmpty
    }

    func signAndAttach(taskID: String, context: ModelContext) async {
        // Önce eski hatayı temizle
        errorMessage = nil

        let trimmedName = signerName.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) İsim kontrolü
        guard !trimmedName.isEmpty else {
            errorMessage = "İsim gerekli."
            return
        }

        // 2) Görsel kontrolü
        guard let image = snapshot else {
            errorMessage = "İmza görseli gerekli."
            return
        }

        isSigning = true
        defer { isSigning = false }

        do {
            // 3) İmzayı kaydet
            _ = try SignatureStore.save(image: image, for: taskID)

            // 4) Görevi bul ve alanları güncelle
            let pred = #Predicate<WorkItem> { $0.id == taskID }
            var fd = FetchDescriptor<WorkItem>(predicate: pred)
            fd.fetchLimit = 1

            guard let task = try context.fetch(fd).first else {
                errorMessage = "Görev bulunamadı."
                return
            }

            task.signatureName = trimmedName
            task.signatureAt = Date()
            task.updatedAt = .now

            try context.save()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
