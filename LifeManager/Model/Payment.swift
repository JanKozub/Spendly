//
//  Payment.swift
//  LifeManager
//
//  Created by Jan Kozub on 01/07/2024.
//

import Foundation

class Payment: Identifiable, Hashable, ObservableObject {
    var id = UUID();
    var issuedDate: String = "";
    var transactionDate: String = "";
    var title: String = "";
    var message: String = "";
    var accountNumber: Int = 0;
    var amount: Double = 0;
    var balance: Double = 0;
    var currency: String = "";
    @Published var category: String = "";
    @Published var type: String = "";
    
    init(id: UUID = UUID(), issuedDate: String, transactionDate: String, title: String, message: String, accountNumber: Int, amount: Double, balance: Double, currency: String, category: String, type: String) {
        self.id = id
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
    
    func setType(_ value: String) {
        self.type = value
    }
    
    static func example() -> Payment {
        Payment(issuedDate: "", transactionDate: "", title: "",
                message: "", accountNumber: 0, amount: 0, balance: 0,
                currency: "",category: "Other", type: "Other")
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
                            currency: cur,
                            category: "Other",
                            type: "Other"
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
        return hasher.combine(id)
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
}
