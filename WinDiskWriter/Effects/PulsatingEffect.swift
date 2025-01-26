//
//  PulsatingEffect.swift
//  WinDiskWriter
//
//  Created by Macintosh on 15.12.2024.
//

import SwiftUI

struct PulsatingEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var isAnimating = false

    private let apply: Bool
    private let delayBetweenCycles: Double
    private let bounceScale: CGFloat

    init(
        apply: Bool,
        delayBetweenCycles: Double = 10,
        bounceScale: CGFloat = 1.09
    ) {
        self.apply = apply
        self.delayBetweenCycles = delayBetweenCycles
        self.bounceScale = bounceScale
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onFirstAppear {
                guard apply else { return }
                startBouncing()
            }
    }

    private func startBouncing() {
        guard !isAnimating else { return }
        isAnimating = true

        Task {
            await performBounceCycle()
        }
    }

    private func performBounceCycle() async {
        let bounceAnimation = Animation.timingCurve(0.4, 0.0, 0.6, 1.0, duration: 0.3)
        let returnAnimation = Animation.easeOut(duration: 0.6)

        await animate(with: bounceAnimation, scale: bounceScale, duration: 0.3)
        await animate(with: returnAnimation, scale: 1.0, duration: 0.2)

        await animate(with: bounceAnimation, scale: bounceScale, duration: 0.3)
        await animate(with: returnAnimation, scale: 1.0, duration: delayBetweenCycles)

        isAnimating = false
        startBouncing()
    }

    private func animate(with animation: Animation, scale: CGFloat, duration: Double) async {
        await MainActor.run {
            withAnimation(animation) {
                self.scale = scale
            }
        }
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
