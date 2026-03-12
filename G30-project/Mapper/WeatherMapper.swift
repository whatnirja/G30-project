import Foundation

struct WeatherMapper {

    static func map(response: WeatherResponse, city: String) -> CityWeather {

        return CityWeather(
            city: city,
            temperature: "\(Int(response.current.temperature))°",
            condition: "\(response.current.weatherCode)",
            highLow: "",
            hourly: [],
            factors: [],
            theme: WeatherTheme.sunny
        )
    }

}
