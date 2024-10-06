import Foundation

class DataParseService {
    static func loadDataFromBank(files: [URL]) -> [Payment] {
        var combinedPayments = [Payment]()
        
        for file in files {
            let payments = loadSantanderPaymentsFromCSV(file: file)
            combinedPayments.append(contentsOf: payments)
        }
        
        combinedPayments = Payment.sortPaymentsByTransactionDate(payments: combinedPayments)
        
        return combinedPayments
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
                            date: Payment.dateFromString(columns[1]) ?? Date(),
                            message: columns[2] + " " + columns[3],
                            amount: Double(columns[5]) ?? -1,
                            currency: Currency.nameToType(name: cur.uppercased(with: .autoupdatingCurrent)),
                            category: PaymentCategory(name: "", graphColor: .red),
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
}
