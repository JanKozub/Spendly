import Foundation
import SwiftData

@Model
class Month: Identifiable ,Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute var monthName: MonthName
    @Attribute var currency: Currency
    @Relationship(deleteRule: .cascade) var payments: [Payment]
    @Relationship(deleteRule: .cascade) var spendings: [PaymentType: Spending]
    @Attribute var income: Double
    
    init(monthName: MonthName, currency: Currency, payments: [Payment], spendings: Dictionary<PaymentType, Spending>, income: Double) {
        self.id = UUID()
        self.monthName = monthName
        self.currency = currency
        self.payments = payments
        self.spendings = spendings
        self.income = income
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
