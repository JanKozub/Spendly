//
//  MonthType.swift
//  LifeManager
//
//  Created by Jan Kozub on 04/07/2024.
//

import Foundation
import SwiftData

enum MonthName: String, Identifiable, CaseIterable, Hashable, Codable {
    case january, februray, march, april, may, june, july, august, september, october, november, december
    
    var id: Int {
        switch self {
        case .january: 1
        case .februray: 2
        case .march: 3
        case .april: 4
        case .may: 5
        case .june: 6
        case .july: 7
        case .august: 8
        case .september: 9
        case .october: 10
        case .november: 11
        case .december: 12
        }
    }
    
    var name: String {
        switch self {
        case .january: "January"
        case .februray: "February"
        case .march: "March"
        case .april: "April"
        case .may: "May"
        case .june: "June"
        case .july: "July"
        case .august: "August"
        case .september: "September"
        case .october: "October"
        case .november: "November"
        case .december: "December"
        }
    }
    
    static func nameToType(name: String) -> MonthName {
        switch name {
        case "January": .january
        case "February": .februray
        case "March": .march
        case "April": .april
        case "May": .may
        case "June": .june
        case "July": .july
        case "August": .august
        case "September": .september
        case "October": .october
        case "November": .november
        case "December": .december
        default: .january
        }
    }
    
    static var allCases: [MonthName] {
        [.january, .februray, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december]
    }
    
    static var allCasesNames: [String] {
        ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    }
    
    static func == (lhs: MonthName, rhs: MonthName) -> Bool {
        lhs.id == rhs.id;
    }
}
