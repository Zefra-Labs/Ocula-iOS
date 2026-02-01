//
//  PrimaryButtonStyle.swift
//  Ocula
//
//  Created by Tyson Miles on 27/1/2026.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.medium(16))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.Colors.accent)
            .cornerRadius(AppTheme.Radius.md)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
