//
//  DataExporter.swift
//  LifeManager
//
//  Created by Jan Kozub on 18/07/2024.
//

import SwiftData
import Foundation
import AppKit

class DataExportService {
    @MainActor
    static func exportToJSON(context: ModelContext) -> Void {
        var years: [Year] = []
        
        do {
            years = try context.fetch(FetchDescriptor<Year>())
        } catch {
            print("Failed fetch context of years") //TODO error handling
            return
        }
        
        let encodableYears = years.map { year in
            EncodableYear(
                id: year.id,
                number: year.number,
                months: year.months.map { month in
                    EncodableMonth(
                        id: month.id,
                        monthName: month.monthName.rawValue,
                        currency: month.currency.rawValue,
                        payments: month.payments.map { payment in
                            EncodablePayment(
                                id: payment.id,
                                issuedDate: payment.issuedDate,
                                transactionDate: payment.transactionDate,
                                title: payment.title,
                                message: payment.message,
                                accountNumber: payment.accountNumber,
                                amount: payment.amount,
                                balance: payment.balance,
                                currency: payment.currency.rawValue,
                                category: payment.category,
                                type: payment.type.rawValue
                            )
                        },
                        spendings: month.spendings.map { (key, value) in
                            EncodableSpending(
                                type: key.rawValue,
                                spending: SpendingDetails(
                                    id: value.id,
                                    sums: Dictionary(uniqueKeysWithValues: value.sums.map { (key, value) in
                                        (key, value)
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
            print("Error while encoing string")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "Testjson.json"
        savePanel.allowedContentTypes = [.json]
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        savePanel.message = "Choose a location to save the JSON file"
        savePanel.prompt = "Save"
        
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
        let issuedDate: String
        let transactionDate: String
        let title: String
        let message: String
        let accountNumber: Int
        let amount: Double
        let balance: Double
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
