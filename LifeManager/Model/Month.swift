//
//  Month.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation
import SwiftData

@Model
class Month: Identifiable ,Hashable {
    @Attribute(.unique) let id: UUID
    @Attribute var monthName: MonthName
    @Attribute var currency: String
    @Relationship var payments: [Payment]
    @Attribute var personalSpendings: Double
    @Attribute var refundedSpendings: Double
    @Attribute var otherSpendings: Double
    @Attribute var income: Double
    
    init(monthName: MonthName, currency: String, payments: [Payment], personalSpendings: Double, refundedSpendings: Double, otherSpendings: Double, income: Double) {
        self.id = UUID()
        self.monthName = monthName
        self.currency = currency
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
