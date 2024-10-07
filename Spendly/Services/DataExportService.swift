import SwiftData
import Foundation
import AppKit

class DataExportService {
    @MainActor
    static func exportToJSON(context: ModelContext) throws -> Void {
        let years = try getYears(context: context)
        
        let jsonString = try encodeData(years: years)
        
        let savePanel = prepareSavePanel()
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try jsonString.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Error saving JSON to file: \(error)")
                    return
                }
            }
        }
    }
    
    private static func getYears(context: ModelContext) throws -> [Year] {
        do {
            return try context.fetch(FetchDescriptor<Year>())
        } catch {
            throw NSError(domain: "Years not found", code: 0, userInfo: ["No years data recorted in the system": 0])
        }
    }
    
    private static func encodeData(years: [Year]) throws -> String {
        let encodableYears = years.map { year in
            EncodableYear(id: year.id, number: year.number, months: year.months.map { month in
                EncodableMonth(id: month.id, monthName: month.monthName.rawValue, currency: month.currency.rawValue,
                    payments: month.payments.map { payment in
                        EncodablePayment(id: payment.id, date: payment.date, message: payment.message,
                            amount: payment.amount, currency: payment.currency.rawValue,
                            category: payment.category.name, type: payment.type.rawValue
                        )
                    },
                    spendings: month.spendings.map { (key, value) in
                        EncodableSpending(
                            type: key.rawValue,
                            spending: SpendingDetails(
                                id: value.id,
                                sums: Dictionary<String, Double>(uniqueKeysWithValues: value.sums.map { (innerKey, innerValue) in
                                    (innerKey.name, innerValue)
                                })
                            )
                        )
                    },
                    income: month.income
                )
            }
            )
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        var jsonString: String = ""
        do {
            jsonString = String(data: try jsonEncoder.encode(encodableYears), encoding: .utf8) ?? ""
        } catch {
            throw NSError(domain: "Error while encoding json", code: 0, userInfo: ["Error while encoding json": 0])
        }
        
        return jsonString
    }
    
    private static func prepareSavePanel() -> NSSavePanel {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "Testjson.json"
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
        let currency: String
        let payments: [EncodablePayment]
        let spendings: [EncodableSpending]
        let income: Double
    }
    
    struct EncodablePayment: Encodable {
        let id: UUID
        let date: Date
        let message: String
        let amount: Double
        let currency: String
        let category: String
        let type: String
    }
    
    struct EncodableSpending: Encodable {
        let type: String
        let spending: SpendingDetails
    }
    
    struct SpendingDetails: Encodable {
        let id: UUID
        let sums: [String: Double]
    }
}
