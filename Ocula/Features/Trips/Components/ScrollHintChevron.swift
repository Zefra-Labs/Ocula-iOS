//
//  ScrollHintChevron.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct ScrollHintChevron: View {
    let isVisible: Bool

    var body: some View {
        Image(systemName: "chevron.compact.forward")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .glassEffect(in: Capsule())
            .padding(.trailing, 6)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.96)
            .allowsHitTesting(false)
    }
}
