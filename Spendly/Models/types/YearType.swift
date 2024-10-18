import Foundation

struct YearType {
    static var allYears: [Int] {
        return (0..<10).map { currentYear - $0 }
    }
    
    static var allYearsNames: [String] {
        allYears.map { String($0) }
    }
    
    static var currentYear: Int {
        return Calendar.current.component(.year, from: Date())
    }
}
