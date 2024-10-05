import Foundation
import SwiftUICore
import SwiftData
import SwiftUI

@Model
class PaymentCategory: Identifiable, Equatable, Codable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    @Attribute() var graphColor: GraphColor

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case graphColor
    }

    init(name: String, graphColor: NSColor) {
        self.id = UUID()
        self.name = name
        self.graphColor = GraphColor(from: graphColor)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(graphColor, forKey: .graphColor)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        graphColor = try container.decode(GraphColor.self, forKey: .graphColor)
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
    
    struct GraphColor: Codable, Equatable {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat

        var color: Color {
            return Color(red: red, green: green, blue: blue)
        }

        init(from color: NSColor) {
            self.red = color.redComponent
            self.green = color.greenComponent
            self.blue = color.blueComponent
        }
    }
}
