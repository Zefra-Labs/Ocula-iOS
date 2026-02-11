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
            .frame(height: 50)
            .background(AppTheme.Colors.accent)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.medium(16))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.secondary)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
struct PrimaryLightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.medium(16))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.accent)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.20 : 0.40)
    }
}
struct PrimaryAuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.medium(16))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.accent)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}
struct SecondaryLightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Fonts.medium(16))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppTheme.Colors.secondary)
            .cornerRadius(25)
            .opacity(configuration.isPressed ? 0.20 : 0.40)
    }
}

