//
//  SignatureCanvas.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 28.10.2025.
//


import SwiftUI
import UIKit
import Combine

/// Controller ile beraber kullanılan SwiftUI köprüsü.
/// `onDrawingBegan` ilk çizgi atıldığında çağrılır.
struct SignatureCanvas: UIViewRepresentable {
    @ObservedObject var controller: SignatureCanvasController
    let lineWidth: CGFloat
    let strokeColor: UIColor
    var onDrawingBegan: (() -> Void)? = nil

    func makeUIView(context: Context) -> SignatureDrawingView {
        let v = SignatureDrawingView()
        v.isOpaque = false
        v.backgroundColor = .clear
        v.lineWidth = lineWidth
        v.strokeColor = strokeColor
        v.onDrawingBegan = {
            onDrawingBegan?()
        }
        controller.attach(view: v)
        return v
    }

    func updateUIView(_ uiView: SignatureDrawingView, context: Context) {
        // Görsel ayarları runtime'da değişirse
        uiView.lineWidth = lineWidth
        uiView.strokeColor = strokeColor
    }
}
