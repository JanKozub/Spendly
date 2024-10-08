import Foundation

struct PaymentGroup: Hashable, Encodable, Decodable {
    var paymentType: PaymentType
    var paymentCategory: PaymentCategory
    
    static func == (lhs: PaymentGroup, rhs: PaymentGroup) -> Bool {
        lhs.paymentType == rhs.paymentType && lhs.paymentCategory == rhs.paymentCategory
    }
}
