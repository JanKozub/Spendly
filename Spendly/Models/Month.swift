import Foundation
import SwiftData

@Model
class Month: Identifiable ,Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute var monthName: MonthName
    @Attribute var yearNum: Int
    @Attribute var groupedExpenses: [PaymentGroup: [Payment]] = [:]
    @Attribute var summedExpenesesInEUR: [PaymentGroup: Double] = [:]
    @Attribute var currenciesInTheMonth: [CurrencyName] = []
    @Attribute var exchangeRates: [CurrencyName: [Date: Double]] = [:] //EUR -> Each currency
    @Attribute var averageExchangeRate: [CurrencyName: Double] = [:]
    @Attribute var income: Double = 0
    @Relationship(deleteRule: .cascade) var payments: [Payment]
    
    init(monthName: MonthName, yearNum: Int) {
        self.id = UUID()
        self.monthName = monthName
        self.yearNum = yearNum
        self.payments = []
    }
    
    public func setPayments(newPayments: [Payment]) async throws {
        self.payments = newPayments
        
        for payment in payments {
            if !self.currenciesInTheMonth.contains(payment.currency) {
                self.currenciesInTheMonth.append(payment.currency)
            }
            
            if payment.category != nil {
                let paymentGroup = PaymentGroup(type: payment.type, category: payment.category!)
                groupedExpenses[paymentGroup, default: []].append(payment)
                summedExpenesesInEUR[paymentGroup, default: 0] += try abs(payment.amount) * getExchangeRateOnDay(from:payment.currency, to: .eur, date: payment.date)
            }
            
            if payment.amount > 0 {
                income += payment.amount
            }
        }
        
        let (firstDay, lastDay) = getFirstAndLastDayOfMonth(year: yearNum, month: monthName)!
        for currency in currenciesInTheMonth {
            if currency != .eur {
                exchangeRates[currency] = try await CurrencyExchangeService.getExchangeRates(base: .eur, target: currency, startDate: firstDay, endDate: lastDay)
            }
            
            var currentDate = firstDay
            var counter = 0
            while currentDate <= lastDay {
                averageExchangeRate[currency, default: 0.0] += exchangeRates[currency]![currentDate]!
                counter += 1
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
            }
            averageExchangeRate[currency, default: 0.0] /= Double(counter)
        }
    }
    
    public func getExpensesForGroup(paymentType: PaymentType, paymentCategory: PaymentCategory, currency: CurrencyName) throws -> Double {
        if !currenciesInTheMonth.contains(currency) {
            throw NSError(domain: "There are no payments with this currency", code: 0)
        }
        
        return summedExpenesesInEUR[PaymentGroup(type: paymentType, category: paymentCategory), default: 0.0] * averageExchangeRate[currency, default: 0.0]
    }
    
    public func getExchangeRateOnDay(from: CurrencyName, to: CurrencyName, date: Date) throws -> Double{
        if from == to {
            return 1.0
        } else {
            if let exchangeRate = exchangeRates[to] {
                return exchangeRate[date]!
            } else {
                throw NSError(domain: "There are no exchange rates for this required currency", code: 0)
            }
        }
    }
    
    private func getFirstAndLastDayOfMonth(year: Int, month: MonthName) -> (firstDay: Date, lastDay: Date)? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let startComponents = DateComponents(year: year, month: month.id, day: 1)
        guard let firstDay = calendar.date(from: startComponents) else {
            return nil
        }
        
        guard let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return nil
        }
        
        let firstDayFinal = calendar.date(byAdding: .day, value: 1, to: firstDay)!
        let lastDay = calendar.date(byAdding: .day, value: range.count, to: firstDay)!
        
        return (firstDayFinal, lastDay)
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
