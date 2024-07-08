//
//  ChartEntry.swift
//  LifeManager
//
//  Created by Jan Kozub on 08/07/2024.
//

import Foundation

struct ChartEntry: Identifiable, Hashable {
    var id = UUID()
    var monthName: MonthName
    var foodSum: Double
    var entertainmentSum: Double
    var otherSum: Double
}
