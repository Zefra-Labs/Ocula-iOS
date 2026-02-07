//
//  Date+RelativeFormatted.swift
//  Ocula
//
//  Created by Tyson Miles on 4/2/2026.
//

import Foundation

extension Date {
    func relativeFormatted() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return formatted(date: .omitted, time: .shortened) }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        return formatted(.dateTime.weekday(.wide))
    }
}
