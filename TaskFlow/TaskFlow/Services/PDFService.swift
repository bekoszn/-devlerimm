//
//  PDFService.swift
//  TaskFlow
//

import Foundation
import PDFKit
import UIKit

public final class PDFService: PDFServiceProtocol {
    public init() {}

    // Çıktı dosya yolu
    public func outputURL(forTaskId id: String) -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("TaskFlow_Report_\(id).pdf")
    }

    // Rapor üretimi
    public func generateReport(for task: WorkItemSnapshot) throws -> URL {
        let url = outputURL(forTaskId: task.id)

        // A4 boyut (72 dpi)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 40
        let contentLeft = margin
        let contentRight = pageRect.width - margin
        let contentWidth = contentRight - contentLeft

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: url) { ctx in
            ctx.beginPage()

            // --- Yardımcılar (closure içinde, ctx erişiyor) ---
            var y: CGFloat = 92
            let lineGap: CGFloat = 24

            func newPageIfNeeded(for nextBlockHeight: CGFloat) {
                // Alt marj: 60 (footer için yer bırak)
                if y + nextBlockHeight > pageRect.height - 80 {
                    // Footer çiz
                    drawLine(from: CGPoint(x: contentLeft, y: pageRect.height - 60),
                             to: CGPoint(x: contentRight, y: pageRect.height - 60))
                    drawText("TaskFlow • Otomatik oluşturuldu",
                             at: CGPoint(x: contentLeft, y: pageRect.height - 48),
                             font: .systemFont(ofSize: 10))

                    ctx.beginPage()
                    // Başlık hattı yeni sayfada atlanır; direkt içerik
                    y = 92
                }
            }

            func drawText(_ text: String, at point: CGPoint, font: UIFont, color: UIColor = .label) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                (text as NSString).draw(at: point, withAttributes: attrs)
            }

            func drawLine(from: CGPoint, to: CGPoint) {
                let path = UIBezierPath()
                path.move(to: from)
                path.addLine(to: to)
                path.lineWidth = 1
                UIColor.separator.setStroke()
                path.stroke()
            }

            func drawLabelValue(label: String, value: String, gap: CGFloat = lineGap) {
                // Etiket + tek satırlık değer
                newPageIfNeeded(for: gap)
                drawText("\(label):", at: CGPoint(x: contentLeft, y: y), font: .boldSystemFont(ofSize: 14))
                drawText(value,       at: CGPoint(x: contentLeft + 100, y: y), font: .systemFont(ofSize: 14))
                y += gap
            }

            func drawMultiline(label: String, value: String, gap: CGFloat = lineGap) {
                // Çok satırlı alan (ör: açıklama)
                let labelFont = UIFont.boldSystemFont(ofSize: 14)
                let valueFont = UIFont.systemFont(ofSize: 14)

                // Label
                newPageIfNeeded(for: gap)
                drawText("\(label):", at: CGPoint(x: contentLeft, y: y), font: labelFont)

                // Value sarma
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping

                let attrs: [NSAttributedString.Key: Any] = [
                    .font: valueFont,
                    .paragraphStyle: paragraph,
                    .foregroundColor: UIColor.label
                ]

                let maxValueWidth = contentWidth - 100
                let bounding = (value as NSString).boundingRect(
                    with: CGSize(width: maxValueWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                )

                newPageIfNeeded(for: max(bounding.height + 10, gap))

                let valueRect = CGRect(
                    x: contentLeft + 100,
                    y: y,
                    width: maxValueWidth,
                    height: ceil(bounding.height)
                )
                (value as NSString).draw(with: valueRect,
                                         options: [.usesLineFragmentOrigin, .usesFontLeading],
                                         attributes: attrs,
                                         context: nil)
                y += max(gap, valueRect.height + 10)
            }

            func drawFooterIfNeededAndFinishPage() {
                drawLine(from: CGPoint(x: contentLeft, y: pageRect.height - 60),
                         to: CGPoint(x: contentRight, y: pageRect.height - 60))
                drawText("TaskFlow • Otomatik oluşturuldu",
                         at: CGPoint(x: contentLeft, y: pageRect.height - 48),
                         font: .systemFont(ofSize: 10))
            }

            // --- Başlık ---
            drawText("Görev Raporu",
                     at: CGPoint(x: contentLeft, y: 40),
                     font: .boldSystemFont(ofSize: 22))
            drawLine(from: CGPoint(x: contentLeft, y: 68),
                     to: CGPoint(x: contentRight, y: 68))

            // --- İçerik ---
            drawLabelValue(label: "Başlık", value: task.title)
            drawLabelValue(label: "Durum", value: task.status.rawValue)

            let desc = task.detail.isEmpty ? "—" : task.detail
            drawMultiline(label: "Açıklama", value: desc)

            if let a = task.assigneeName, !a.isEmpty {
                drawLabelValue(label: "Atanan", value: a)
            }
            if let l = task.locationName, !l.isEmpty {
                drawLabelValue(label: "Konum", value: l)
            }
            if let d = task.deadline {
                drawLabelValue(label: "Bitiş",
                               value: d.formatted(date: .abbreviated, time: .shortened))
            }

            // --- İmza Bölümü ---
            let hasSignatureText = (task.signatureName?.isEmpty == false) || (task.signatureAt != nil)
            let signatureImage = SignatureStore.image(for: task.id)

            if hasSignatureText || signatureImage != nil {
                // Bölüm başlığı + ayraç
                y += 16
                newPageIfNeeded(for: 36) // başlık ve ilk satırlar için alan ayır
                drawLine(from: CGPoint(x: contentLeft, y: y - 8),
                         to: CGPoint(x: contentRight, y: y - 8))
                drawText("İmza",
                         at: CGPoint(x: contentLeft, y: y),
                         font: .boldSystemFont(ofSize: 16))
                y += 16 // ⬅️ BAŞLIKTAN SONRA BOŞLUK — çakışmayı önler

                if let name = task.signatureName, !name.isEmpty {
                    drawLabelValue(label: "İmzalayan", value: name, gap: 20)
                }
                if let d = task.signatureAt {
                    drawLabelValue(label: "İmza Tarihi",
                                   value: d.formatted(date: .abbreviated, time: .shortened),
                                   gap: 20)
                }

                if let img = signatureImage {
                    // Görsel tamamen sol marjdan başlar, sayfa içine sığdırılır
                    let maxW = contentWidth            // taşma yok
                    let preferredW: CGFloat = 300      // estetik hedef genişlik
                    let targetW = min(preferredW, maxW)

                    let scale = targetW / img.size.width
                    var targetH = img.size.height * scale

                    // Kalan dikey alan yetersizse yeni sayfa
                    if y + targetH + 20 > pageRect.height - 80 {
                        drawFooterIfNeededAndFinishPage()
                        ctx.beginPage()
                        y = 92
                        // (İstersen yeni sayfada tekrar küçük “İmza” başlığı atabilirsin)
                        drawText("İmza",
                                 at: CGPoint(x: contentLeft, y: y),
                                 font: .boldSystemFont(ofSize: 16))
                        y += 16
                    }

                    // Yine de çok uzunsa, kalan alana sığacak kadar küçült
                    let remainingH = (pageRect.height - 80) - y
                    if targetH > remainingH {
                        let shrinkScale = remainingH / targetH
                        targetH *= shrinkScale
                    }

                    let imgRect = CGRect(x: contentLeft, y: y, width: targetW, height: targetH)
                    let borderRect = imgRect.insetBy(dx: -6, dy: -6)

                    // Arka plan + çerçeve
                    let bgPath = UIBezierPath(roundedRect: borderRect, cornerRadius: 10)
                    UIColor(white: 0.97, alpha: 1.0).setFill()
                    bgPath.fill()
                    UIColor.separator.setStroke()
                    bgPath.lineWidth = 1
                    bgPath.stroke()

                    img.draw(in: imgRect)
                    y = borderRect.maxY + 12
                }
            }

            // --- Footer ---
            drawFooterIfNeededAndFinishPage()
        }

        return url
    }
}
