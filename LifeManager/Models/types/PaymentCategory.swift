//
//  CategoryType.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation
import SwiftData

@Model
class PaymentCategory: Identifiable, Equatable, Encodable, Decodable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    static func getDefault() -> [String] {
        return [
            "Entertainment",
            "Groceries",
            "For Parents",
            "Fuel",
            "Gift",
            "New Things",
            "Going out",
            "Subscriptions",
            "Transport",
            "Other"
        ]
    }
    
    static func convertToStringArray(inputArray: [PaymentCategory]) -> [String] {
        var temp: [String] = []
        for el in inputArray {
            temp.append(el.name)
        }
        
        return temp
    }
    
    static func == (lhs: PaymentCategory, rhs: PaymentCategory) -> Bool {
        lhs.name == rhs.name
    }
}
