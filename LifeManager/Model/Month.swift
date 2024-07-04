//
//  Month.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation

class Month: Identifiable ,Hashable {
    var id = UUID()
    var monthType: MonthType
    var payments: [Payment]
    var personalSpendings: Double
    var refundedSpendings: Double
    var otherSpendings: Double
    var income: Double
    
    init(id: UUID = UUID(), monthType: MonthType, payments: [Payment], personalSpendings: Double, refundedSpendings: Double, otherSpendings: Double, income: Double) {
        self.id = id
        self.monthType = monthType
        self.payments = payments
        self.personalSpendings = personalSpendings
        self.refundedSpendings = refundedSpendings
        self.otherSpendings = otherSpendings
        self.income = income
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
