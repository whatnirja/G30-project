struct CityWeather {
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double

    let temperature: String
    let condition: String
    let highLow: String

    let hourly: [HourlyForecast]
    let factors: [StormFactor]
    let alerts: [String]
    let stormRiskScore: Int    
    let theme: WeatherTheme
}
