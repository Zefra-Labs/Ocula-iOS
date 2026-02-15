//
//  StatCircleView.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct StatCircleView: View {

    let number: Int
    let title: String
    let icon: String
    let size: CGFloat
    let isPrimary: Bool

    @State private var isPressed = false
    @State private var animatedValue: Double = 0

    // MARK: - Scaling
    private var scale: CGFloat {
        isPrimary ? 0.90 : 0.80
    }

    private var contentColor: Color {
        isPrimary ? .white : AppTheme.Colors.primary
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {

            Image(systemName: icon)
                .foregroundColor(contentColor)
                .font(.system(size: size * 0.18 * scale))

            // Animated number
            Text("")
                .modifier(CountingText(value: animatedValue))
                .foregroundColor(contentColor)
                .font(.system(
                    size: size * 0.36 * scale,
                    weight: .bold
                ))

            Text(title)
                .foregroundColor(AppTheme.Colors.primary)
                .font(.system(
                    size: size * 0.14 * scale,
                    weight: isPrimary ? .bold : .semibold
                ))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: size, height: size)
        .background(
            Circle()
                .fill(
                    isPrimary
                    ? AppTheme.Colors.accent.opacity(0.75)
                    : AppTheme.Colors.surfaceDark
                )
        )
        .scaleEffect(isPressed ? 0.96 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isPressed = false
            }
        }
        .onAppear {
            animatedValue = 0
            withAnimation(.easeOut(duration: isPrimary ? 0.9 : 0.6)) {
                animatedValue = Double(number)
            }
        }
    }
}

private struct CountingText: AnimatableModifier {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        Text("\(Int(value))")
    }
}
