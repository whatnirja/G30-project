import Foundation

struct GeoMetCityPageMapper {

    static func map(dto: GeoMetCityPageDTO, city: String, country: String, lat: Double, lon: Double) -> CityWeather {
        let props = dto.properties

        let currentTempValue = props.currentConditions?.temperature?.value?.en
        let currentTemp      = currentTempValue.map { "\(Int($0))°" } ?? "--°"

        let forecasts     = props.forecastGroup?.forecasts ?? []
        let todayForecast = forecasts.first
        let highLow       = makeHighLow(from: forecasts)

        let condition =
            props.currentConditions?.condition?.en ??
            todayForecast?.cloudPrecip?.en ??
            todayForecast?.textSummary?.en ??
            props.forecastGroup?.textSummary?.en ??
            "Unknown"

        let alerts  = (props.warnings ?? []).compactMap { $0.description?.en }
        let factors = computeBasicFactors(from: condition)
        let score   = computeRiskScore(from: condition, alertCount: alerts.count)

        return CityWeather(
            city:           city,
            country:        country,
            latitude:       lat,
            longitude:      lon,
            temperature:    currentTemp,
            condition:      condition,
            highLow:        highLow,
            hourly:         [],
            factors:        factors,
            alerts:         alerts,
            stormRiskScore: score,
            theme:          theme(from: condition)
        )
    }

    // MARK: - Called by WeatherCacheStorage too

    static func computeBasicFactors(from condition: String) -> [StormFactor] {
        var factors: [StormFactor] = []
        let lower = condition.lowercased()

        if lower.contains("tornado")                               { factors.append(.init(title: "Tornado Warning",  icon: "tornado",              value: "Active",   severity: .severe))   }
        if lower.contains("thunder") || lower.contains("lightning"){ factors.append(.init(title: "Thunderstorm",    icon: "cloud.bolt.fill",      value: "Active",   severity: .severe))   }
        if lower.contains("hail")                                  { factors.append(.init(title: "Hail",            icon: "cloud.hail.fill",      value: "Possible", severity: .severe))   }
        if lower.contains("blizzard")                              { factors.append(.init(title: "Blizzard",        icon: "wind.snow",            value: "Active",   severity: .severe))   }
        if lower.contains("freezing") || lower.contains("ice")     { factors.append(.init(title: "Freezing Rain",  icon: "thermometer.snowflake",value: "Active",   severity: .high))     }
        if lower.contains("snow") || lower.contains("flurr")       { factors.append(.init(title: "Snow / Flurries",icon: "cloud.snow.fill",      value: "Active",   severity: .high))     }
        if lower.contains("rain") || lower.contains("shower") || lower.contains("drizzle") {
            factors.append(.init(title: "Precipitation", icon: "cloud.rain.fill", value: "Active", severity: .moderate))
        }
        if lower.contains("wind") || lower.contains("gust")        { factors.append(.init(title: "Strong Winds",  icon: "wind",                 value: "Active",   severity: .high))     }
        if lower.contains("fog")  || lower.contains("mist")        { factors.append(.init(title: "Low Visibility",icon: "cloud.fog.fill",       value: "Active",   severity: .moderate)) }

        if factors.isEmpty {
            factors.append(.init(title: "Clear Conditions", icon: "sun.max.fill", value: "Normal", severity: .low))
        }
        return factors
    }

    static func computeRiskScore(from condition: String, alertCount: Int) -> Int {
        var score = 0
        let lower = condition.lowercased()

        if      lower.contains("tornado")                                { score += 85 }
        else if lower.contains("thunder") || lower.contains("lightning") { score += 60 }
        else if lower.contains("blizzard")                               { score += 55 }
        else if lower.contains("freezing") || lower.contains("ice")      { score += 45 }
        else if lower.contains("storm")                                  { score += 42 }
        else if lower.contains("snow")   || lower.contains("flurr")      { score += 32 }
        else if lower.contains("rain")   || lower.contains("shower")     { score += 24 }
        else if lower.contains("wind")   || lower.contains("gust")       { score += 18 }
        else if lower.contains("fog")    || lower.contains("mist")       { score += 12 }
        else if lower.contains("cloud")  || lower.contains("overcast")   { score += 8  }
        else if lower.contains("sun")    || lower.contains("clear")      { score += 2  }

        score += min(alertCount * 10, 25)
        return min(score, 100)
    }

    // MARK: - Private

    private static func makeHighLow(from forecasts: [GeoMetCityPageDTO.ForecastPeriodDTO]) -> String {
        var high: Int?
        var low: Int?

        for forecast in forecasts.prefix(3) {
            guard let temps = forecast.temperatures?.temperature else { continue }
            for temp in temps {
                guard let value = temp.value?.en else { continue }
                let intValue  = Int(value)
                let tempClass = temp.className?.en?.lowercased() ?? ""
                if tempClass == "high"     { if high == nil || intValue > high! { high = intValue } }
                else if tempClass == "low" { if low  == nil || intValue < low!  { low  = intValue } }
                else {
                    if high == nil || intValue > high! { high = intValue }
                    if low  == nil || intValue < low!  { low  = intValue }
                }
            }
        }

        switch (high, low) {
        case let (h?, l?):  return "H:\(h)°  L:\(l)°"
        case let (h?, nil): return "H:\(h)°"
        case let (nil, l?): return "L:\(l)°"
        default:            return ""
        }
    }

    private static func theme(from condition: String) -> WeatherTheme {
        let lower = condition.lowercased()
        if lower.contains("thunder") || lower.contains("storm")                             { return .storm }
        if lower.contains("snow") || lower.contains("flurr") || lower.contains("ice")       { return .snowy }
        if lower.contains("rain") || lower.contains("drizzle") || lower.contains("shower")  { return .rainy }
        if lower.contains("wind")                                                            { return .windy }
        if lower.contains("cloud") || lower.contains("fog") || lower.contains("overcast")   { return .cloudy }
        if lower.contains("sun")   || lower.contains("clear")                               { return .sunny }
        return .defaultTheme
    }
}
