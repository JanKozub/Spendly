//
//  Year.swift
//  LifeManager
//
//  Created by Jan Kozub on 05/07/2024.
//

import Foundation
import SwiftData

@Model
class Year: Identifiable {
    @Attribute(.unique) let id: UUID
    @Attribute var number: Int
    @Relationship var months: [Month]
    
    init(number: Int, months: [Month]) {
        self.id = UUID()
        self.number = number
        self.months = months
    }
}
