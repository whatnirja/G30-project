import Foundation

struct StormNotification: Identifiable, Hashable {
    let id: Int
    let city: String
    let title: String
    let message: String
    let source: String
    let severity: Severity
    let issuedAt: Date
    let notificationKey: String

    enum Severity: String, Codable {
        case severe
        case high
        case moderate
        case low

        var systemImage: String {
            switch self {
            case .severe: return "tornado"
            case .high: return "exclamationmark.triangle.fill"
            case .moderate: return "exclamationmark.circle.fill"
            case .low: return "checkmark.shield.fill"
            }
        }
    }
}

extension StormNotification {
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: issuedAt)
    }
}
