import SwiftUI

enum WeatherTheme {
    case rainy, cloudy, sunny, storm, snowy, windy, defaultTheme

    var gradient: [Color] {
        switch self {
        case .sunny:
            return [Color.white, Color.yellow.opacity(0.05), Color.orange.opacity(0.35)] 
        case .cloudy:
            return [Color.white, Color.gray.opacity(0.25), Color.gray.opacity(0.35)]
        case .rainy:
            return [Color.white, Color.blue.opacity(0.05), Color.blue.opacity(0.35)]
        case .storm:
            return [Color.white, Color.blue.opacity(0.05), Color.black.opacity(0.90)]
        case .snowy:
            return [Color.white, Color.cyan.opacity(0.25), Color.blue.opacity(0.50)]
        case .windy:
            return [Color.white, Color.mint.opacity(0.08), Color.gray.opacity(0.65)]
        case .defaultTheme:
            return [Color.white, Color.gray.opacity(0.15), Color.blue.opacity(0.55)]
        }
    }
}
