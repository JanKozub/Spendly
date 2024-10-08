import Foundation

struct PaymentGroup: Hashable, Encodable, Decodable {
    var type: PaymentType
    var category: PaymentCategory
    
    static func == (lhs: PaymentGroup, rhs: PaymentGroup) -> Bool {
        lhs.type == rhs.type && lhs.category == rhs.category
    }
}
