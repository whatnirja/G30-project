import Foundation

struct WeatherMapper {
    static func map(response: WeatherResponse, city: String) -> CityWeather {
        let high = Int(response.hourly.temperature.max() ?? response.current.temperature)
        let low  = Int(response.hourly.temperature.min() ?? response.current.temperature)

        let condition = weatherCondition(from: response.current.weatherCode)
        let factors   = GeoMetCityPageMapper.computeBasicFactors(from: condition)
        let score     = GeoMetCityPageMapper.computeRiskScore(from: condition, alertCount: 0)

        return CityWeather(
            city:           city,
            country:        "Canada",
            latitude:       0.0,
            longitude:      0.0,
            temperature:    "\(Int(response.current.temperature))°",
            condition:      condition,
            highLow:        "H:\(high)°  L:\(low)°",
            hourly:         [],
            factors:        factors,
            alerts:         [],
            stormRiskScore: score,
            theme:          theme(from: response.current.weatherCode)
        )
    }

    private static func weatherCondition(from code: Int) -> String {
        switch code {
        case 0:                          return "Clear"
        case 1, 2, 3:                    return "Cloudy"
        case 45, 48:                     return "Fog"
        case 51, 53, 55, 61, 63, 65,
             80, 81, 82:                 return "Rain"
        case 71, 73, 75, 85, 86:         return "Snow"
        case 95, 96, 99:                 return "Thunderstorm"
        default:                         return "Unknown"
        }
    }

    private static func theme(from code: Int) -> WeatherTheme {
        switch code {
        case 71, 73, 75, 85, 86:         return .snowy
        case 51, 53, 55, 61, 63, 65,
             80, 81, 82:                 return .rainy
        case 95, 96, 99:                 return .storm
        case 1, 2, 3, 45, 48:           return .cloudy
        default:                         return .sunny
        }
    }
}
