import SwiftData
import Foundation
import AppKit

class DataExportService {
    @MainActor
    static func exportToJSON(context: ModelContext) throws {
        let years = try getYears(context: context)
        
        let jsonString = try encodeData(years: years)
        
        let savePanel = prepareSavePanel()
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try jsonString.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Error saving JSON to file: \(error)")
                }
            }
        }
    }
    
    private static func getYears(context: ModelContext) throws -> [Year] {
        return try context.fetch(FetchDescriptor<Year>())
    }
    
    private static func encodeData(years: [Year]) throws -> String {
        let encodableYears = years.map { year in
            EncodableYear(
                id: year.id,
                number: year.number,
                months: year.months.map { month in
                    EncodableMonth(
                        id: month.id,
                        monthName: month.monthName.rawValue,
                        groupedExpenses: month.groupedExpenses.mapKeys { group in
                            EncodablePaymentGroup(type: group.type.rawValue, category: group.category.name)
                        }.mapValues { payments in
                            payments.map { payment in
                                EncodablePayment(
                                    id: payment.id,
                                    date: ISO8601DateFormatter().string(from: payment.date),
                                    message: payment.message,
                                    amount: payment.amount,
                                    currency: payment.currency.rawValue,
                                    category: payment.category!.name,
                                    type: payment.type.rawValue
                                )
                            }
                        },
                        summedExpenesesInEUR: month.summedExpenesesInEUR.mapKeys { group in
                            EncodablePaymentGroup(type: group.type.rawValue, category: group.category.name)
                        },
                        currenciesInMonth: month.currenciesInTheMonth.map { $0.rawValue },
                        exchangeRates: month.exchangeRates.mapKeys { $0.rawValue }.mapValues { rates in
                            rates.mapKeys { ISO8601DateFormatter().string(from: $0) }
                        },
                        averageExchangeRate: month.averageExchangeRate.mapKeys { $0.rawValue },
                        payments: month.payments.map { payment in
                            EncodablePayment(
                                id: payment.id,
                                date: ISO8601DateFormatter().string(from: payment.date),
                                message: payment.message,
                                amount: payment.amount,
                                currency: payment.currency.rawValue,
                                category: payment.category!.name,
                                type: payment.type.rawValue
                            )
                        }
                    )
                }
            )
        }

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData = try jsonEncoder.encode(encodableYears)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "DataExportService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON"])
        }
        
        return jsonString
    }
    
    private static func prepareSavePanel() -> NSSavePanel {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "ExportedData.json"
        savePanel.allowedContentTypes = [.json]
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        savePanel.message = "Choose a location to save the JSON file"
        savePanel.prompt = "Save"
        
        return savePanel
    }
    
    struct EncodableYear: Encodable {
        let id: UUID
        let number: Int
        let months: [EncodableMonth]
    }
    
    struct EncodableMonth: Encodable {
        let id: UUID
        let monthName: String
        let groupedExpenses: [EncodablePaymentGroup: [EncodablePayment]]
        let summedExpenesesInEUR: [EncodablePaymentGroup: Double]
        let currenciesInMonth: [String]
        let exchangeRates: [String: [String: Double]]
        let averageExchangeRate: [String: Double]
        let payments: [EncodablePayment]
    }
    
    struct EncodablePayment: Encodable {
        let id: UUID
        let date: String
        let message: String
        let amount: Double
        let currency: String
        let category: String
        let type: String
    }
    
    struct EncodableExpenseGroup: Encodable {
        let type: String
        let category: String
        let sum: Double
    }
    
    struct EncodablePaymentGroup: Encodable, Hashable {
        let type: String
        let category: String
    }
}

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        return Dictionary<T, Value>(uniqueKeysWithValues: try map { (key, value) in (try transform(key), value) })
    }
}
