//
//  Payment.swift
//  LifeManager
//
//  Created by Jan Kozub on 01/07/2024.
//

import Foundation
import SwiftData

@Model
class Payment: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) let id: UUID
    @Attribute var issuedDate: String
    @Attribute var transactionDate: String
    @Attribute var title: String
    @Attribute var message: String
    @Attribute var accountNumber: Int
    @Attribute var amount: Double
    @Attribute var balance: Double
    @Attribute var currency: Currency
    @Attribute var category: String
    @Attribute var type: PaymentType
    
    init(issuedDate: String, transactionDate: String, title: String, message: String, accountNumber: Int, amount: Double, balance: Double, currency: Currency, category: String, type: PaymentType) {
        self.id = UUID()
        self.issuedDate = issuedDate
        self.transactionDate = transactionDate
        self.title = title
        self.message = message
        self.accountNumber = accountNumber
        self.amount = amount
        self.balance = balance
        self.currency = currency
        self.category = category
        self.type = type
    }
    
    static func example() -> Payment {
        Payment(issuedDate: "", transactionDate: "", title: "",
                message: "", accountNumber: 0, amount: 0, balance: 0,
                currency: .pln, category: "", type: .personal)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
}
