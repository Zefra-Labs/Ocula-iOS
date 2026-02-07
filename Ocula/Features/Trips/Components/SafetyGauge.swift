//
//  SafetyGauge.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct SafetyGauge: View {
    let title: String
    let value: Int

    var normalized: Double {
        min(Double(value) / 10.0, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)

            Gauge(value: normalized) { }
                .gaugeStyle(.accessoryLinear)
                .tint(normalized > 0.6 ? .red : normalized > 0.3 ? .orange : .green)

            Text("\(value) incidents")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
