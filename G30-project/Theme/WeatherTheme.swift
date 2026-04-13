import SwiftUI

enum WeatherTheme {
    case rainy, cloudy, sunny, storm, snowy, windy, defaultTheme

    var gradient: [Color] {
        switch self {
        case .sunny:
            return [Color.yellow.opacity(0.6), Color.orange.opacity(0.8)]

        case .cloudy:
            return [Color.gray.opacity(0.5), Color.gray.opacity(0.8)]

        case .rainy:
            return [Color.blue.opacity(0.6), Color.indigo.opacity(0.8)]

        case .storm:
            return [Color.black.opacity(0.85), Color.blue.opacity(0.7)]

        case .snowy:
            return [Color.cyan.opacity(0.5), Color.blue.opacity(0.6)]

        case .windy:
            return [Color.mint.opacity(0.5), Color.gray.opacity(0.6)]

        case .defaultTheme:
            return [Color.blue.opacity(0.5), Color.gray.opacity(0.5)]
        }
    }
}
