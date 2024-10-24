import Foundation

struct ExchangeRate: Codable {
    var from: CurrencyName
    var to: CurrencyName
    var date: PaymentDate
    var rate: Double
}
