//
//  View+Styles.swift
//  Ocula
//
//  Created by Tyson Miles on 27/1/2026.
//
import SwiftUI

extension View {

    func titleStyle() -> some View {
        self.modifier(TitleText())
    }

    func bodyStyle() -> some View {
        self.modifier(BodyText())
    }

    func captionStyle() -> some View {
        self.modifier(CaptionText())
    }
    func headlineStyle() -> some View {
        self.modifier(Headline())
    }
    func headlineBoldStyle() -> some View {
        self.modifier(HeadlineBold())
    }
    func title2Style() -> some View{
        self.modifier(TitleText2())
    }
    func subheadline() -> some View{
        self.modifier(subHeadline())
    }
}

