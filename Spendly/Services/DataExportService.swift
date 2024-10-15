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
                        monthName: month.monthName,
                        yearNum: month.yearNum,
                        payments: month.payments,
                        incomePayments: month.incomePayments,
                        expensePayments: month.expensePayments,
                        exchangeRates: month.exchangeRates,
                        currenciesInTheMonth: month.currenciesInTheMonth
                    )
                }
            )
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(encodableYears)
        return String(data: jsonData, encoding: .utf8) ?? ""
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
}

struct EncodableYear: Codable {
    var id: UUID
    var number: Int
    var months: [EncodableMonth]
}

struct EncodableMonth: Codable {
    var id: UUID
    var monthName: MonthName
    var yearNum: Int
    var payments: [Payment]
    var incomePayments: [Payment]
    var expensePayments: [Payment]
    var exchangeRates: [ExchangeRate]
    var currenciesInTheMonth: [CurrencyName]
}
