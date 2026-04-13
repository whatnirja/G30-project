import Foundation

final class OpenMeteoService {
    static let shared = OpenMeteoService()
    private init() {}

    struct HourlyResult {
        let forecasts: [HourlyForecast]
        let currentWindspeed: Double
        let currentPrecipProb: Int
    }

    private struct Response: Decodable {
        let hourly: HourlyData

        struct HourlyData: Decodable {
            let time: [String]
            let temperature2m: [Double]
            let precipitationProbability: [Int]
            let weathercode: [Int]
            let windspeed10m: [Double]

            enum CodingKeys: String, CodingKey {
                case time
                case temperature2m             = "temperature_2m"
                case precipitationProbability  = "precipitation_probability"
                case weathercode
                case windspeed10m              = "windspeed_10m"
            }
        }
    }

    func fetchHourlyData(lat: Double, lon: Double) async throws -> HourlyResult {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            .init(name: "latitude",       value: String(format: "%.4f", lat)),
            .init(name: "longitude",      value: String(format: "%.4f", lon)),
            .init(name: "hourly",         value: "temperature_2m,precipitation_probability,weathercode,windspeed_10m"),
            .init(name: "forecast_days",  value: "1"),
            .init(name: "timezone",       value: "auto"),
            .init(name: "timeformat",     value: "iso8601"),
            .init(name: "wind_speed_unit",value: "kmh"),
        ]

        guard let url = comps.url else { throw APIError.invalidURL }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response  = try JSONDecoder().decode(Response.self, from: data)
        let h         = response.hourly

        let currentHour = Calendar.current.component(.hour, from: Date())
        let startIdx    = min(currentHour, max(0, h.time.count - 1))
        let endIdx      = min(startIdx + 12, h.time.count)

        let forecasts: [HourlyForecast] = (startIdx..<endIdx).enumerated().map { enumIdx, idx in
            let hour        = extractHour(from: h.time[idx])
            let displayTime = enumIdx == 0 ? "Now" : formatHour(hour)
            return HourlyForecast(
                time:   displayTime,
                icon:   weatherIcon(for: h.weathercode[idx]),
                temp:   "\(Int(round(h.temperature2m[idx])))°",
                precip: "\(h.precipitationProbability[idx])%"
            )
        }

        let currentWind   = startIdx < h.windspeed10m.count             ? h.windspeed10m[startIdx]            : 0
        let currentPrecip = startIdx < h.precipitationProbability.count ? h.precipitationProbability[startIdx] : 0

        return HourlyResult(forecasts: forecasts, currentWindspeed: currentWind, currentPrecipProb: currentPrecip)
    }

    private func extractHour(from iso: String) -> Int {
        guard let tIdx = iso.firstIndex(of: "T") else { return 0 }
        let timePart = String(iso[iso.index(after: tIdx)...])
        return Int(timePart.prefix(2)) ?? 0
    }

    private func formatHour(_ hour: Int) -> String {
        let h    = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h)\(ampm)"
    }

    func weatherIcon(for code: Int) -> String {
        switch code {
        case 0:              return "sun.max.fill"
        case 1, 2:           return "cloud.sun.fill"
        case 3:              return "cloud.fill"
        case 45, 48:         return "cloud.fog.fill"
        case 51, 53, 55:     return "cloud.drizzle.fill"
        case 61, 63:         return "cloud.rain.fill"
        case 65, 80, 81, 82: return "cloud.heavyrain.fill"
        case 71, 73, 75,
             85, 86:         return "cloud.snow.fill"
        case 95:             return "cloud.bolt.fill"
        case 96, 99:         return "cloud.bolt.rain.fill"
        default:             return "cloud.fill"
        }
    }
}
