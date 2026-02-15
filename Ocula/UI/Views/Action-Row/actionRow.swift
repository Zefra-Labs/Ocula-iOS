//
//  actionRow.swift
//  Ocula
//
//  Created by Tyson Miles on 28/1/2026.
//

import SwiftUI

enum ActionRowStyle {
    case card
    case list
}

@ViewBuilder
func actionRow(
    icon: String,
    iconColor: Color? = nil,
    title: String,
    subtitle: String,
    trailingValue: String? = nil,
    destination: AnyView? = nil,
    action: (() -> Void)? = nil,
    style: ActionRowStyle = .card
) -> some View {
    
    let rowContent = HStack(spacing: 16) {
        
        Image(systemName: icon)
            .title2Style()
            .foregroundColor(iconColor ?? AppTheme.Colors.primary)
            .frame(width: 25)
        
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .headlineStyle()
                .lineLimit(1)
            
            Text(subtitle)
                .captionStyle()
                .lineLimit(2)
        }
        
        Spacer()
        
        if let trailingValue {
            Text(trailingValue)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)
        }

        if style == .card {
            Image(systemName: "chevron.right")
                .bodyStyle()
                .foregroundColor(AppTheme.Colors.secondary)
        }
    }
    let styledContent = Group {
        if style == .card {
            rowContent
                .padding(AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xlg)
                        .fill(AppTheme.Colors.primary.opacity(0.08))
                )
        } else {
            rowContent
        }
    }
    
    if let destination {
        if style == .card {
            NavigationLink { destination } label: { styledContent }
                .buttonStyle(PressableRowStyle())
        } else {
            NavigationLink { destination } label: { styledContent }
        }
    } else {
        if style == .card {
            Button(action: { action?() }) {
                styledContent
            }
            .buttonStyle(PressableRowStyle())
        } else {
            Button(action: { action?() }) {
                styledContent
            }
        }
    }
}
struct PressableRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xlg, style: .continuous)
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.08 : 0))
            )
            .animation(.easeOut(duration: 0.25), value: configuration.isPressed)
    }
}
