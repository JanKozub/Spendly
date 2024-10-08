import Foundation

class DataParseService {
    static func loadDataFromBank(files: [URL]) throws -> [Payment] {
        var combinedPayments = [Payment]()
        
        for file in files {
            let payments = try loadSantanderPaymentsFromCSV(file: file)
            combinedPayments.append(contentsOf: payments)
        }
        
        return Payment.sortPaymentsByTransactionDate(payments: combinedPayments)
    }
    
    static func loadSantanderPaymentsFromCSV(file: URL) throws -> [Payment] {
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
                        if (columns[1].isEmpty || columns[5].isEmpty) {
                            throw NSError(domain: "Parsing error for date or amonunt field", code: 0)
                        }
                        
                        let payment = Payment(
                            date: Payment.dateFromString(columns[1])!,
                            message: columns[2] + " " + columns[3],
                            amount: Double(columns[5])!,
                            currency: CurrencyName.nameToType(name: cur.uppercased(with: .autoupdatingCurrent)),
                            category: PaymentCategory(name: "", graphColor: .red),
                            type: .personal
                        )
                        newPayments.append(payment);
                    }
                }
            }
            return newPayments;
        } catch {
            throw NSError(domain: "Parsing error", code: 0, userInfo: ["Parsing error": 0])
        }
    }
}
