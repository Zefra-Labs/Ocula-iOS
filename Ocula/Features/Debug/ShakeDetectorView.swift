//
//  ShakeDetectorView.swift
//  Ocula
//
//  Created by Tyson Miles on 2/15/2026.
//

import SwiftUI

struct ShakeDetectorView: UIViewRepresentable {
    let onShake: () -> Void

    func makeUIView(context: Context) -> ShakeDetectingUIView {
        let view = ShakeDetectingUIView()
        view.onShake = onShake
        return view
    }

    func updateUIView(_ uiView: ShakeDetectingUIView, context: Context) {
        uiView.onShake = onShake
    }
}

final class ShakeDetectingUIView: UIView {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            becomeFirstResponder()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        onShake?()
    }
}
