import Foundation
import SwiftData

@Model
class Month: Identifiable ,Hashable {
    @Attribute(.unique) var id: UUID
    @Attribute var monthName: MonthName
    @Attribute var yearNum: Int
    @Relationship(deleteRule: .cascade) var payments: [Payment]
    @Attribute private var incomePayments: [Payment]
    @Attribute private var expensePayments: [Payment]
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
    
    public func getRateOnDay(from: CurrencyName, to: CurrencyName, date: PaymentDate) async throws -> Double {
        if from == to {
            return 1.0
        }
        
        var exchangeRate = exchangeRates.first(where: { $0.from == from && $0.to == to && $0.date == date})
        
        if exchangeRate == nil {
            exchangeRate = try await CurrencyExchangeService.getExchangeRate(from: from, to: to, startDate: date, endDate: date)[0]
        }
        
        return exchangeRate!.rate
    }
    
    public func getExpenseByPaymentAndCategory(type: PaymentType, category: PaymentCategory, currency: CurrencyName) async throws -> Double {
        if expensePayments.isEmpty {
            return 0.0
        }
        
        var sum = 0.0
        for payment in expensePayments where payment.type == type && payment.category == category {
            if payment.currency == currency {
                sum += abs(payment.amount)
                continue
            }
            
            if (!exchangeRates.contains(where: { $0.from == payment.currency && $0.to == currency})) {
                let (firstDay, lastDay) = try getFirstAndLastDate(year: yearNum, month: payment.date.month)
                exchangeRates.append(contentsOf: try await CurrencyExchangeService.getExchangeRate(from: payment.currency, to: currency, startDate: firstDay, endDate: lastDay))
            }
            
            if let rate = exchangeRates.first(where: { $0.date == payment.date }) {
                sum += abs(payment.amount) * rate.rate
            } else {
                throw NSError(domain: "No rate for date: \(payment.date)", code: 0)
            }
        }
        
        return sum
    }
    
    private func getFirstAndLastDate(year: Int, month: Int) throws -> (firstDay: PaymentDate, lastDay: PaymentDate) {
        let calendar = Calendar.current

        var dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let rangeOfDays = calendar.range(of: .day, in: .month, for: calendar.date(from: dateComponents)!) else {
            fatalError("Could not determine range of days in month")
        }

        dateComponents.day = rangeOfDays.count
        guard let endOfMonth = calendar.date(from: dateComponents) else {
            fatalError("Could not create end of the month date")
        }
        
        return (PaymentDate(day: 1, month: month, year: year), PaymentDate.dateToPaymentDate(date: endOfMonth))
    }
    
    public func removePayment(payment: Payment) {
        if (payment.amount > 0) {
            incomePayments.remove(at: incomePayments.firstIndex(of: payment)!)
        }
        
        payments.removeAll(where: { $0.id == payment.id })
        incomePayments.removeAll(where: { $0.id == payment.id })
        expensePayments.removeAll(where: { $0.id == payment.id })
    }
    
    public func getExpensePayments() -> [Payment] {
        return expensePayments
    }
    
    public func getIncomePayments() -> [Payment] {
        return incomePayments
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
