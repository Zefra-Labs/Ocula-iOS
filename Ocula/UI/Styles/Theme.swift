//
//  Styles.swift
//  Ocula
//
//  Created by Tyson Miles on 27/1/2026.
//

import SwiftUI

enum AppTheme {

    enum Colors {
        static let background = Color("Background")
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
        static let accent = Color("Accent")
        static let surfaceDark = Color("Dark")
        static let destructive = Color.red
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let mdlg: CGFloat = 18
        static let lg: CGFloat = 20
        static let xlg: CGFloat = 25
        static let xxlg: CGFloat = 30
    }

    enum Fonts {
        static func regular(_ size: CGFloat) -> Font {
            .system(size: size, weight: .regular)
        }

        static func medium(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium)
        }

        static func bold(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold)
        }
        static func semibold(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold)
        }
        
    }
}
