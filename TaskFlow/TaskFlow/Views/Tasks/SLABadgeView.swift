//
//  SLABadgeView.swift
//  TaskFlow
//
//  Created by Berke Özgüder on 24.10.2025.
//
import SwiftUI

struct SLABadgeView: View {
    let sla: SLA
    var showText: Bool = false
    var body: some View {
        let state = sla.state()
        let text: String = {
            switch state { case .normal: return "On Track"; case .warning: return "Yaklaşıyor"; case .critical: return "Kritik"; case .overdue: return "Gecikti" }
        }()
        HStack(spacing: 6) {
            Circle().frame(width: 10, height: 10).foregroundStyle(color(for: state))
            if showText { Text(text).font(.subheadline).foregroundStyle(.secondary) }
        }
        .padding(8).background(.ultraThinMaterial, in: Capsule()).accessibilityLabel(Text(text))
    }
    private func color(for s: SLA.State) -> Color { switch s { case .normal: return .green; case .warning: return .orange; case .critical: return .red; case .overdue: return .purple } }
}

