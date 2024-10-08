import Foundation
import SwiftData

@Model
class Payment: Identifiable, Hashable, ObservableObject, Encodable, Decodable {
    @Attribute(.unique) var id: UUID
    @Attribute var date: Date
    @Attribute var message: String
    @Attribute var amount: Double
    @Attribute var currency: CurrencyName
    @Attribute var category: PaymentCategory
    @Attribute var type: PaymentType
    
    init(date: Date, message: String, amount: Double, currency: CurrencyName, category: PaymentCategory, type: PaymentType) {
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
        Payment(date: Date(), message: "", amount: 0, currency: .pln, category: PaymentCategory.example(), type: .personal)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id
    }
    
    static func sortPaymentsByTransactionDate(payments: [Payment]) -> [Payment] {
        return payments.sorted { $0.date > $1.date }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case message
        case amount
        case currency
        case category
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        message = try container.decode(String.self, forKey: .message)
        amount = try container.decode(Double.self, forKey: .amount)
        currency = try container.decode(CurrencyName.self, forKey: .currency)
        category = try container.decode(PaymentCategory.self, forKey: .category)
        type = try container.decode(PaymentType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(message, forKey: .message)
        try container.encode(amount, forKey: .amount)
        try container.encode(currency, forKey: .currency)
        try container.encode(category, forKey: .category)
        try container.encode(type, forKey: .type)
    }
    
    public func copy() -> Payment {
        return Payment(date: self.date,
                       message: self.message,
                       amount: self.amount,
                       currency: self.currency,
                       category: self.category,
                       type: self.type)
    }
    
    public func getGroupOfPayment() -> PaymentGroup {
        return PaymentGroup(type: self.type, category: self.category)
    }
    
    public func getTypeAndCurrencyGroup() -> TypeAndCurrencyGroup {
        return TypeAndCurrencyGroup(type: self.type, currency: self.currency)
    }
}
