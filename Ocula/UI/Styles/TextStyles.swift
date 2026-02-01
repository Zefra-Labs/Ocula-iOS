//
//  TitleText.swift
//  Ocula
//
//  Created by Tyson Miles on 27/1/2026.
//


import SwiftUI

struct TitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Fonts.bold(28))
            .foregroundColor(AppTheme.Colors.primary)
    }
}

struct BodyText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Fonts.regular(16))
            .foregroundColor(AppTheme.Colors.secondary)
            .lineSpacing(4)
    }
}

struct CaptionText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTheme.Fonts.medium(13))
            .foregroundColor(.gray)
    }
}
