import Foundation
import SwiftData

@Model
class Payment: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) var id: UUID
    @Attribute var transactionDate: String
    @Attribute var title: String
    @Attribute var message: String
    @Attribute var amount: Double
    @Attribute var balance: Double
    @Attribute var currency: Currency
    @Attribute var category: String
    @Attribute var type: PaymentType
    
    init(transactionDate: String, title: String, message: String, amount: Double, balance: Double, currency: Currency, category: String, type: PaymentType) {
        self.id = UUID()
        self.transactionDate = transactionDate
        self.title = title
        self.message = message
        self.amount = amount
        self.balance = balance
        self.currency = currency
        self.category = category
        self.type = type
    }
    
    static func example() -> Payment {
        Payment(transactionDate: "", title: "",
                message: "", amount: 0, balance: 0,
                currency: .pln, category: "", type: .personal)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
    
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: dateString)
    }
    
    static func sortPaymentsByTransactionDate(payments: [Payment]) -> [Payment] {
        return payments.sorted {
            guard let date1 = $0.dateFromString($0.transactionDate),
                  let date2 = $1.dateFromString($1.transactionDate) else { return false }
            return date1 > date2
        }
    }
}
