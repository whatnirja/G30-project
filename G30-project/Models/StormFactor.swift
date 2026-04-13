import SwiftUI

enum FactorSeverity {
    case low, moderate, high, severe

    var color: Color {
        switch self {
        case .low:      return Color.green
        case .moderate: return Color(red: 0.95, green: 0.75, blue: 0.10)
        case .high:     return Color.orange
        case .severe:   return Color.red
        }
    }

    var label: String {
        switch self {
        case .low:      return "Low"
        case .moderate: return "Moderate"
        case .high:     return "High"
        case .severe:   return "Severe"
        }
    }
}

struct StormFactor: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let value: String 
    let severity: FactorSeverity
}
