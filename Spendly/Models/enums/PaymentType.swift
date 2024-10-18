import Foundation
import SwiftData

enum PaymentType: String, Identifiable, CaseIterable, Hashable, Codable {
    case personal, refunded
    
    var id: Int {
        switch self {
        case .personal: 1
        case .refunded: 2
        }
    }
    
    var name: String {
        switch self {
        case .personal: "Personal"
        case .refunded: "Refunded"
        }
    }
    
    static func nameToType(name: String) -> PaymentType {
        switch name {
        case "Personal": .personal
        case "Refunded": .refunded
        default: .personal
        }
    }
    
    static var allCases: [PaymentType] {
        [.personal, .refunded]
    }
    
    static var allCasesNames: [String] {
        ["Personal", "Refunded"]
    }
    
    static func == (lhs: PaymentType, rhs: PaymentType) -> Bool {
        lhs.id == rhs.id
    }
}
