//
//  StatusStepperView.swift
//  TaskFlow
//

import SwiftUI

struct StatusStepperView: View {
    let status: TaskStatus
    var onPrev: () -> Void
    var onNext: () -> Void

    private var canPrev: Bool { status.previous() != nil }
    private var canNext: Bool { status.next() != nil }

    var body: some View {
        VStack(spacing: 12) {
            // Step indicators
            HStack(spacing: 8) {
                ForEach(TaskStatus.allCases, id: \.self) { s in
                    StepItem(title: s.displayTitle, isActive: s == status, color: s.tintColor)
                        .frame(maxWidth: .infinity)
                }
            }

            // Controls
            HStack(spacing: 10) {
                Button(action: onPrev) {
                    Label("Geri", systemImage: "chevron.left.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canPrev)
                .opacity(canPrev ? 1 : 0.5)
                .buttonStyle(.plain)
                .foregroundStyle(.white)

                Spacer()

                Text(status.displayTitle)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onNext) {
                    Label("İleri", systemImage: "chevron.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canNext)
                .opacity(canNext ? 1 : 0.5)
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))
    }

    private struct StepItem: View {
        let title: String
        let isActive: Bool
        let color: Color

        var body: some View {
            VStack(spacing: 6) {
                Circle()
                    .fill(isActive ? color : Color.white.opacity(0.25))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle().stroke(color.opacity(isActive ? 0.7 : 0.3), lineWidth: 1)
                    )
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.75))
            }
            .padding(.vertical, 6)
        }
    }
}
