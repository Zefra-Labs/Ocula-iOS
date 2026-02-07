//
//  IncidentCard.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

struct IncidentCard: View {
    let title: String
    let count: Int
    let icon: String

    var body: some View {
        HStack {
            Circle()
                .fill(count > 0 ? .orange : .green)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .fontWeight(.bold)
                )

            VStack(alignment: .leading) {
                Text(title)
                Text(count > 0 ? "\(count) detected" : "None detected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.xlg))
    }
}
