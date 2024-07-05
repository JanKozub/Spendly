//
//  CategoryType.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation
import SwiftData

enum PaymentCategory: String, Identifiable, CaseIterable, Hashable, Codable {
    case food, entertainmanet, other
    
    var id: Int {
        switch self {
        case .food: 1
        case .entertainmanet: 2
        case .other: 3
        }
    }
    
    var name: String {
        switch self {
        case .food: "Food"
        case .entertainmanet: "Entertainment"
        case .other: "Other"
        }
    }
    
    static func nameToType(name: String) -> PaymentCategory {
        switch name {
        case "Food": .food
        case "Entertainment": .entertainmanet
        case "Other": .other
        default: .other
        }
    }
    
    static var allCases: [PaymentCategory] {
        [.food, .entertainmanet, .other]
    }
    
    static var allCasesNames: [String] {
        ["Food", "Entertainment", "Other"]
    }
    
    static func == (lhs: PaymentCategory, rhs: PaymentCategory) -> Bool {
        lhs.id == rhs.id
    }
}
