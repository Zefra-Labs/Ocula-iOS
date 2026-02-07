//
//  SafetyScoreStyle.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

enum SafetyScoreStyle {
    static func icon(for score: Int) -> String {
        if score < 50 {
            return "gauge.with.dots.needle.0percent"
        } else if score <= 80 {
            return score < 65
                ? "gauge.with.dots.needle.50percent"
                : "gauge.with.dots.needle.67percent"
        } else {
            return "gauge.with.dots.needle.100percent"
        }
    }

    static func subtitle(for score: Int) -> String {
        if score < 20 {
            return "Needs a loooooot of work"
        } else if score <= 60 {
            return score < 40
                ? "Needs some more work"
                : "Needs a bit more work"
        } else if score <= 80 {
            return score < 65
                ? "Needs just a little work"
                : "Almost there!"
        } else if score <= 99 {
            return score < 95
                ? "Keep up the great work!"
                : "So Close! Keep going!"
        } else if score >= 100 {
            return "Amazing work!"
        } else {
            return "Keep up the great work!"
        }
    }

    static func color(for score: Int) -> Color {
        if score < 50 { return .red }
        if score <= 80 { return .yellow }
        return .green
    }
}
