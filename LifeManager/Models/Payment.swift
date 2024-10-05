import Foundation
import SwiftData

@Model
class Payment: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) var id: UUID
    @Attribute var date: Date
    @Attribute var message: String
    @Attribute var amount: Double
    @Attribute var currency: Currency
    @Attribute var category: String
    @Attribute var type: PaymentType
    
    init(date: Date, message: String, amount: Double, currency: Currency, category: String, type: PaymentType) {
        self.id = UUID()
        self.date = date
        self.message = message
        self.amount = amount
        self.currency = currency
        self.category = category
        self.type = type
    }

    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
    
    static func dateFromString(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: date)
    }
    
    static func example() -> Payment {
        Payment(date: Date(), message: "", amount: 0, currency: .pln, category: "", type: .personal)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
    
    static func sortPaymentsByTransactionDate(payments: [Payment]) -> [Payment] {
        return payments.sorted { $0.date > $1.date }
    }
}
