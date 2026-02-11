//
//  OculaOrbView.swift
//  Ocula
//
//  Created by Tyson Miles on 2/10/2026.
//

import SwiftUI

struct OculaOrbView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.accent.opacity(0.9),
                            AppTheme.Colors.accent.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.accent.opacity(0.35), lineWidth: 1)
                )

            Circle()
                .stroke(AppTheme.Colors.accent.opacity(0.2), lineWidth: 6)
                .scaleEffect(pulse ? 1.15 : 0.98)
                .opacity(pulse ? 0.25 : 0.45)
        }
        .frame(width: 72, height: 72)
        .shadow(color: AppTheme.Colors.accent.opacity(0.25), radius: 16, x: 0, y: 8)
        .scaleEffect(pulse ? 1.04 : 0.98)
        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)
        .onAppear { pulse = true }
        .accessibilityHidden(true)
    }
}
