import Foundation

extension CityWeather {
    static let mockToronto = CityWeather(
        city:           "Toronto",
        country:        "Canada",
        latitude:       43.7001,
        longitude:      -79.4163,
        temperature:    "19°",
        condition:      "Mostly Rainy",
        highLow:        "H: 24°  |  L: 18°",
        hourly: [
            .init(time: "Now", icon: "cloud.rain.fill",      temp: "19°", precip: "30%"),
            .init(time: "2AM", icon: "cloud.drizzle.fill",   temp: "18°", precip: "25%"),
            .init(time: "3AM", icon: "cloud.rain.fill",      temp: "19°", precip: "35%"),
            .init(time: "4AM", icon: "cloud.rain.fill",      temp: "19°", precip: "40%"),
            .init(time: "5AM", icon: "cloud.bolt.rain.fill", temp: "19°", precip: "45%"),
        ],
        factors: [
            .init(title: "Precipitation", icon: "cloud.rain.fill", value: "72%",      severity: .high),
            .init(title: "Wind Speed",    icon: "wind",            value: "38 km/h",  severity: .moderate),
            .init(title: "Hail",          icon: "cloud.hail.fill", value: "Possible", severity: .severe),
        ],
        alerts:         ["Rainfall Warning in effect for the Toronto and Golden Horseshoe region."],
        stormRiskScore: 62,
        theme:          .rainy
    )

    static let mockLondon = CityWeather(
        city:           "London",
        country:        "Canada",
        latitude:       42.9849,
        longitude:      -81.2453,
        temperature:    "3°",
        condition:      "Heavy Rain",
        highLow:        "H: 16°  |  L: 8°",
        hourly: [
            .init(time: "Now", icon: "cloud.heavyrain.fill", temp: "3°", precip: "70%"),
            .init(time: "2AM", icon: "cloud.heavyrain.fill", temp: "2°", precip: "75%"),
            .init(time: "3AM", icon: "cloud.rain.fill",      temp: "2°", precip: "60%"),
        ],
        factors: [
            .init(title: "Precipitation", icon: "cloud.heavyrain.fill", value: "70%",     severity: .high),
            .init(title: "Flood Risk",    icon: "water.waves",          value: "Elevated", severity: .high),
            .init(title: "Wind Speed",    icon: "wind",                 value: "22 km/h",  severity: .moderate),
        ],
        alerts:         [],
        stormRiskScore: 48,
        theme:          .rainy
    )

    static let mockWindsor = CityWeather(
        city:           "Windsor",
        country:        "Canada",
        latitude:       42.3149,
        longitude:      -83.0364,
        temperature:    "-9°",
        condition:      "Storm Incoming",
        highLow:        "H: 24°  |  L: -18°",
        hourly: [
            .init(time: "Now", icon: "cloud.bolt.rain.fill", temp: "-9°",  precip: "55%"),
            .init(time: "2AM", icon: "cloud.bolt.rain.fill", temp: "-10°", precip: "60%"),
            .init(time: "3AM", icon: "cloud.snow.fill",      temp: "-11°", precip: "40%"),
        ],
        factors: [
            .init(title: "Thunderstorm", icon: "cloud.bolt.fill", value: "Active",   severity: .severe),
            .init(title: "Wind Speed",   icon: "wind",            value: "65 km/h",  severity: .severe),
            .init(title: "Snow Squalls", icon: "cloud.snow.fill", value: "Possible", severity: .high),
        ],
        alerts: [
            "Severe Thunderstorm Warning in effect.",
            "Winter Storm Watch issued for Windsor–Essex region.",
        ],
        stormRiskScore: 84,
        theme:          .storm
    )
}

enum MockNotifications {
    static let items: [StormNotification] = [
        .init(title: "Tornado Warning",           timeText: "10:15 AM",           level: .severe),
        .init(title: "Severe Thunderstorm Alert", timeText: "8:30 AM",            level: .high),
        .init(title: "Flood Watch Issued",        timeText: "Yesterday, 4:00 PM", level: .moderate),
        .init(title: "Wind Advisory",             timeText: "9:15 AM",            level: .moderate),
        .init(title: "Winter Storm Alert",        timeText: "April 12, 2:00 PM",  level: .low),
    ]
}
