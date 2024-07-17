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
    @Attribute var category: PaymentCategory
    @Attribute var type: PaymentType
    
    init(issuedDate: String, transactionDate: String, title: String, message: String, accountNumber: Int, amount: Double, balance: Double, currency: Currency, category: PaymentCategory, type: PaymentType) {
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
                currency: .pln, category: .other, type: .personal)
    }
    
    static func loadSantanderPaymentsFromCSV(file: URL) -> [Payment] {
        do {
            let fileContent = try String(contentsOf: file, encoding: .utf8)
            let rows = fileContent.components(separatedBy: "\n")
            var newPayments = [Payment]()
            var cur = ""
            for(index, line) in rows.enumerated() {
                let columns = line.replacingOccurrences(of: ",", with: ".").components(separatedBy: ";");
                if columns.count == 9 {
                    if index == 0 {
                        cur = columns[4]
                    } else {
                        let payment = Payment(
                            issuedDate: columns[0],
                            transactionDate: columns[1],
                            title: columns[2],
                            message:columns[3],
                            accountNumber: Int(columns[4]) ?? -1,
                            amount: Double(columns[5]) ?? -1,
                            balance: Double(columns[6]) ?? -1,
                            currency: Currency.nameToType(name: cur.uppercased(with: .autoupdatingCurrent)),
                            category: .other,
                            type: .personal
                        )
                        newPayments.append(payment);
                    }
                }
            }
            return newPayments;
        } catch {
            print("error: \(error)")
            return []
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
}
