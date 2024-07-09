//
//  Currency.swift
//  LifeManager
//
//  Created by Jan Kozub on 09/07/2024.
//

import Foundation
import SwiftData

enum Currency: String, Identifiable, CaseIterable, Hashable, Codable {
    case pln, eur
    
    var id: Int {
        switch self {
        case .pln: 1
        case .eur: 2
        }
    }
    
    var name: String {
        switch self {
        case .pln: "PLN"
        case .eur: "EUR"
        }
    }
    
    static func exchangeRate(from: Currency, to: Currency) -> Double { //TODO connect API
        if from == to {
            return 1.0
        }
        
        if from == .eur && to == .pln {
            return 4.26
        } else if from == .pln && to == .eur {
            return 0.23
        } else {
            return 0.0
        }
    }
    
    static func nameToType(name: String) -> Currency {
        switch name {
        case "PLN": .pln
        case "EUR": .eur
        default: .pln
        }
    }
    
    static var allCases: [Currency] {
        [.pln, .eur]
    }
    
    static var allCasesNames: [String] {
        ["PLN", "EUR"]
    }
    
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.id == rhs.id
    }
}
