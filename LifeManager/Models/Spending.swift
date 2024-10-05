import Foundation
import SwiftData

@Model
class Spending: Identifiable, Hashable, Encodable, Decodable {
    @Attribute(.unique) var id: UUID
    @Attribute var sums: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case id
        case sums
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sums = try container.decode([String: Double].self, forKey: .sums)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sums, forKey: .sums)
    }
    
    init(sums: [String: Double]) {
        self.id = UUID()
        self.sums = sums
    }
    
    func overallSum() -> Double {
        var sum = 0.0
        
        for n in sums {
            sum += n.value
        }
        
        return sum
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
