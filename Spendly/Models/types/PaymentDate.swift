import Foundation

struct PaymentDate: Comparable, Encodable, Decodable {
    var day: Int
    var month: Int
    var year: Int
    
    mutating func addDays(_ days: Int) {
        self.day += days
    }
    
    static func dateToPaymentDate(date: Date) -> PaymentDate {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return PaymentDate(day: components.day!, month: components.month!, year: components.year!)
    }
    
    static func dateFromString(strDate: String) -> PaymentDate {
        let values = strDate.split(separator: "-")
        return PaymentDate(day: Int(values[0])!, month: Int(values[1])!, year: Int(values[2])!)
    }
    
    static func dateFromStringFormatter(strDate: String, formatter: String) -> PaymentDate {
        let df = DateFormatter()
        df.dateFormat = formatter
        let date = df.date(from: strDate)!
        return dateToPaymentDate(date: date)
    }
    
    static func dateToStringDot(date: PaymentDate) -> String {
        return "\(date.day).\(date.month).\(date.year)"
    }
    
    static func dateToStringFormatter(date: PaymentDate, formatter: String) -> String {
        var components = DateComponents()
        components.day = date.day
        components.month = date.month
        components.year = date.year
        let date = Calendar.current.date(from: components)!
        let df = DateFormatter()
        df.dateFormat = formatter
        return df.string(from: date)
    }
    
    static func today() -> PaymentDate {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        return PaymentDate(day: components.day!, month: components.month!, year: components.year!)
    }
    
    static func == (lhs: PaymentDate, rhs: PaymentDate) -> Bool {
        lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
    }
    
    static func < (lhs: PaymentDate, rhs: PaymentDate) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        } else {
            return lhs.day < rhs.day
        }
    }
}
