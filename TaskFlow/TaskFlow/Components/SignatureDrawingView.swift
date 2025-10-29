//
//  SignatureDrawingView.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 28.10.2025.
//


import UIKit
import Combine

final class SignatureCanvasController: ObservableObject {
    @Published var isEmpty: Bool = true

    private weak var view: SignatureDrawingView?

    func attach(view: SignatureDrawingView) {
        self.view = view
    }

    func clear() {
        view?.clear()
        isEmpty = true
    }

    /// SENKRON snapshot üretir; ilk basışta bile nil dönmez (çizim varsa).
    func captureSnapshot() -> UIImage? {
        guard let v = view else { return nil }
        return v.renderImage()
    }
}

/// Basit çizim view'i
final class SignatureDrawingView: UIView {
    var lineWidth: CGFloat = 2.0
    var strokeColor: UIColor = .white

    private var path = UIBezierPath()
    private var points: [CGPoint] = []
    var onDrawingBegan: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isMultipleTouchEnabled = false
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = lineWidth
        backgroundColor = .clear

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        let p = gr.location(in: self)

        switch gr.state {
        case .began:
            onDrawingBegan?()
            points = [p]
            path = UIBezierPath()
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.lineWidth = lineWidth
            path.move(to: p)
        case .changed:
            points.append(p)
            path.addLine(to: p)
            setNeedsDisplay()
        case .ended, .cancelled:
            setNeedsDisplay()
        default:
            break
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        strokeColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

    func clear() {
        path.removeAllPoints()
        points.removeAll()
        setNeedsDisplay()
    }

    /// View içeriğini görüntüye dönüştürür (SENKRON).
    func renderImage(scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        let image = renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
        // Tamamen boşsa (hiç çizgi yoksa) şeffaf PNG döner — üst katman VM kontrol eder
        return image
    }
}
