import Foundation

struct ExchangeRate: Codable {
    var from: CurrencyName
    var to: CurrencyName
    var date: Date
    var rate: Double
}
