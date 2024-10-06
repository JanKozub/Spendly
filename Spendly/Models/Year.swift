import Foundation
import SwiftData

@Model
class Year: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID
    @Attribute var number: Int
    @Relationship var months: [Month]
    
    init(number: Int, months: [Month]) {
        self.id = UUID()
        self.number = number
        self.months = months
    }
    
    static func == (lhs: Year, rhs: Year) -> Bool {
        lhs.number == rhs.number
    }
}
