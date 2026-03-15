import Foundation

struct GeoMetCityPageMapper {
    static func map(dto: GeoMetCityPageDTO) -> CityWeather {
        let props = dto.properties

        let cityName = props.name.en ?? "Unknown City"

        let currentTempValue = props.currentConditions?.temperature?.value?.en
        let currentTemp = currentTempValue.map { "\(Int($0))°" } ?? "--°"

        let todayForecast = props.forecastGroup?.forecasts?.first

        let condition =
            props.currentConditions?.condition?.en ??
            todayForecast?.cloudPrecip?.en ??
            todayForecast?.textSummary?.en ??
            props.forecastGroup?.textSummary?.en ??
            "Unknown"

        let highLow = makeHighLow(from: todayForecast)

        return CityWeather(
            city: cityName,
            temperature: currentTemp,
            condition: condition,
            highLow: highLow,
            hourly: [],
            factors: [],
            theme: theme(from: condition)
        )
    }

    private static func makeHighLow(from forecast: GeoMetCityPageDTO.ForecastPeriodDTO?) -> String {
        guard let temps = forecast?.temperatures?.temperature else {
            return ""
        }

        var high: Int?
        var low: Int?

        for temp in temps {
            guard let value = temp.value?.en else { continue }
            let intValue = Int(value)
            let tempClass = temp.className?.en?.lowercased() ?? ""

            if tempClass == "high" {
                high = intValue
            } else if tempClass == "low" {
                low = intValue
            } else {
                if high == nil || intValue > high! { high = intValue }
                if low == nil || intValue < low! { low = intValue }
            }
        }

        switch (high, low) {
        case let (h?, l?):
            return "H:\(h)°  L:\(l)°"
        case let (h?, nil):
            return "H:\(h)°"
        case let (nil, l?):
            return "L:\(l)°"
        default:
            return ""
        }
    }

    private static func theme(from condition: String) -> WeatherTheme {
        let lower = condition.lowercased()

        if lower.contains("thunder") || lower.contains("storm") {
            return .storm
        } else if lower.contains("snow") || lower.contains("flurr") || lower.contains("ice") {
            return .snowy
        } else if lower.contains("rain") || lower.contains("drizzle") || lower.contains("shower") {
            return .rainy
        } else if lower.contains("wind") {
            return .windy
        } else if lower.contains("cloud") || lower.contains("fog") || lower.contains("overcast") {
            return .cloudy
        } else if lower.contains("sun") || lower.contains("clear") {
            return .sunny
        } else {
            return .defaultTheme
        }
    }
}
