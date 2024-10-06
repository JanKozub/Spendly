import Foundation

struct ChartEntry: Identifiable, Hashable {
    var id: UUID
    var monthName: MonthName
    var paymentType: PaymentType
    var sums: Dictionary<PaymentCategory, Double>
    
    init(monthName: MonthName, categories: [PaymentCategory]) {
        self.id = UUID()
        self.monthName = monthName
        self.paymentType = .personal
        self.sums = [:]
        
        for category in categories {
            self.sums[category] = 0
        }
    }
    
    init(monthName: MonthName, paymentType: PaymentType, categories: [PaymentCategory]) {
        self.id = UUID()
        self.monthName = monthName
        self.paymentType = paymentType
        self.sums = [:]
        
        for category in categories {
            self.sums[category] = 0
        }
    }
}
