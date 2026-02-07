import Foundation

struct StormNotification: Identifiable {
    let id = UUID()
    let title: String
    let timeText: String
    let level: Level

    enum Level {
        case severe
        case high
        case moderate
        case low
    }
}
