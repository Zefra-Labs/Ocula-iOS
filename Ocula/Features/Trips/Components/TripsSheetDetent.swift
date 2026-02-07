//
//  TripsSheetDetent.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import SwiftUI

enum TripsSheetDetent: CaseIterable {
    case collapsed
    case large

    func height(availableHeight: CGFloat) -> CGFloat {
        switch self {
        case .collapsed:
            return max(70, availableHeight * 0.12)
        case .large:
            return availableHeight * 0.75
        }
    }
}
