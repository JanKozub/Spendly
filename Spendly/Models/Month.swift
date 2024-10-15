import Foundation
import SwiftData

@Model
class Month: Identifiable ,Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute var monthName: MonthName
    @Attribute var yearNum: Int
    @Relationship(deleteRule: .cascade) var payments: [Payment]
    @Attribute var incomePayments: [Payment]
    @Attribute var expensePayments: [Payment]
    @Attribute var exchangeRates: [ExchangeRate] = []
    @Attribute var currenciesInTheMonth: [CurrencyName] = []

    
    init(monthName: MonthName, yearNum: Int) {
        self.id = UUID()
        self.monthName = monthName
        self.yearNum = yearNum
        self.payments = []
        self.incomePayments = []
        self.expensePayments = []
    }
    
    public func setPayments(newPayments: [Payment]) async throws {
        self.payments = newPayments
        
        processPayments()
        
        let (firstDay, lastDay) = try getFirstAndLastDate(year: yearNum, month: monthName)
        
        for currency in currenciesInTheMonth {
            if currency != .eur {
                exchangeRates = try await CurrencyExchangeService.getExchangeRates(from: currency, to: .eur, startDate: firstDay, endDate: lastDay)
            }
        }
    }
    
    private func processPayments() {
        for payment in payments {
            if !self.currenciesInTheMonth.contains(payment.currency) {
                self.currenciesInTheMonth.append(payment.currency)
            }
            
            if payment.amount > 0 {
                incomePayments.append(payment)
            } else {
                expensePayments.append(payment)
            }
        }
    }
    
    public func getRateOnDay(from: CurrencyName, to: CurrencyName, date: Date) throws -> Double {
        if from == to {
            return 1.0
        } else {
            let exchangeRate = exchangeRates.first(where: { $0.from == from && $0.to == to && $0.date == date})
            
            if exchangeRate == nil {
                throw NSError(domain: "There are no exchange rates for required currency", code: 0)
            }
            
            return exchangeRate!.rate
        }
    }
    
    public func getExpensesForGroup(paymentType: PaymentType, paymentCategory: PaymentCategory, currency: CurrencyName) throws -> Double {
        if !currenciesInTheMonth.contains(currency) {
            throw NSError(domain: "There are no payments with this currency", code: 0)
        }
        
        var sum = 0.0
        
        for payment in expensePayments {
            if payment.type == paymentType && payment.category == paymentCategory {
                
                if payment.currency == currency {
                    sum += payment.amount
                } else {
                    sum += payment.amount * (try getRateOnDay(from: payment.currency, to: currency, date: payment.date))
                }
            }
        }
        
        return sum
    }
    
    private func getFirstAndLastDate(year: Int, month: MonthName) throws -> (firstDay: Date, lastDay: Date) {
        var firstDay = payments[0].date
        var lastDay = payments[0].date
        
        for payment in payments {
            if payment.date < firstDay {
                firstDay = payment.date
            }
            
            if payment.date > lastDay {
                lastDay = payment.date
            }
        }
        
        let calendar = Calendar.current
        return (calendar.date(byAdding: .day, value: 1, to: firstDay)!, calendar.date(byAdding: .day, value: 1, to: lastDay)!)
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
