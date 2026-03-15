import Foundation

struct WeatherResponse: Decodable {

    let current: CurrentWeatherDTO
    let hourly: HourlyWeatherDTO

}

struct CurrentWeatherDTO: Decodable {

    let temperature: Double
    let windSpeed: Double
    let weatherCode: Int

}

struct HourlyWeatherDTO: Decodable {

    let time: [String]
    let temperature: [Double]
    let precipitationProbability: [Double]

}
