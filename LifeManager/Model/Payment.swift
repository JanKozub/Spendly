//
//  Payment.swift
//  LifeManager
//
//  Created by Jan Kozub on 01/07/2024.
//

import Foundation

struct Payment: Identifiable, Hashable {
    var id = UUID();
    var issuedDate: String;
    var transactionDate: String;
    var title: String;
    var message: String;
    var accountNumber: Int;
    var amount: Double;
    var balance: Double;
    var currency: String;
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id;
    }
    
    static func example() -> Payment {
        Payment(issuedDate: "", transactionDate: "", title: "", message: "", accountNumber: 0, amount: 0, balance: 0, currency: "")
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
                    }
                    
                    let payment = Payment(
                        issuedDate: columns[0],
                        transactionDate: columns[1],
                        title: columns[2],
                        message:columns[3],
                        accountNumber: Int(columns[4]) ?? -1,
                        amount: Double(columns[5]) ?? -1,
                        balance: Double(columns[6]) ?? -1,
                        currency: cur
                    )
                    newPayments.append(payment);
                }
            }
            return newPayments;
        } catch {
            print("error: \(error)")
            return []
        }
    }
}
