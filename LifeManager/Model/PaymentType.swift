//
//  PaymentType.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation


enum PaymentType: Identifiable, CaseIterable, Hashable {
    case personal
    case refunded
    case other
    
    var id: Int {
        switch self {
        case .personal: 1
        case .refunded: 2
        case .other: 3
        }
    }
    
    var name: String {
        switch self {
        case .personal: "Personal"
        case .refunded: "Refunded"
        case .other: "Other"
        }
    }
    
    static func nameToType(name: String) -> PaymentType {
        switch name {
        case "Personal": .personal
        case "Refunded": .refunded
        case "Other": .other
        default: .other
        }
    }
    
    static var allCases: [PaymentType] {
        [.personal, .refunded, .other]
    }
    
    static var allCasesNames: [String] {
        ["Personal", "Refunded", "Other"]
    }
    
    static func == (lhs: PaymentType, rhs: PaymentType) -> Bool {
        lhs.id == rhs.id
    }
}
