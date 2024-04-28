//
//  Date+AdjustedYear.swift
//  WinDiskWriter
//
//  Created by Macintosh on 27.04.2024.
//

import Foundation

extension Date {
    static var adjustedYear: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        
        return max(year, 2024)
    }
}
