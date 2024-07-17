//
//  ChartEntry.swift
//  LifeManager
//
//  Created by Jan Kozub on 08/07/2024.
//

import Foundation

struct ChartEntry: Identifiable, Hashable {
    var id: UUID
    var monthName: MonthName
    var paymentType: PaymentType
    var sums: Dictionary<PaymentCategory, Double>
    
    init(monthName: MonthName) {
        self.id = UUID()
        self.monthName = monthName
        self.paymentType = .personal
        self.sums = [:]
        
        for category in PaymentCategory.allCases {
            self.sums[category] = 0
        }
    }
    
    init(monthName: MonthName, paymentType: PaymentType) {
        self.id = UUID()
        self.monthName = monthName
        self.paymentType = paymentType
        self.sums = [:]
        
        for category in PaymentCategory.allCases {
            self.sums[category] = 0
        }
    }
}
