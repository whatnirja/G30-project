struct CityWeather {
    let city: String
    let temperature: String
    let condition: String
    let highLow: String
    let hourly: [HourlyForecast]
    let factors: [StormFactor]
    let theme: WeatherTheme
}
