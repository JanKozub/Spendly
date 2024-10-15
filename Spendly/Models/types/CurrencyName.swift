import Foundation
import SwiftData

enum CurrencyName: String, Identifiable, CaseIterable, Hashable, Codable {
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
    
    static func nameToType(name: String) -> CurrencyName {
        switch name {
        case "PLN": .pln
        case "EUR": .eur
        default: .pln
        }
    }
    
    static func typeToStringArray(input: [CurrencyName]) -> [String] {
        var output: [String] = []
        for val in input {
            output.append(val.name)
        }
        
        return output
    }
    
    static var allCases: [CurrencyName] {
        [.pln, .eur]
    }
    
    static var allCasesNames: [String] {
        ["PLN", "EUR"]
    }
    
    static func == (lhs: CurrencyName, rhs: CurrencyName) -> Bool {
        lhs.id == rhs.id
    }
}
