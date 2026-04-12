import Foundation

final class WeatherService {
    static let shared = WeatherService()
    private init() {}

    func fetchWeather(for city: String) async throws -> CityWeather {
        guard let stationID = CityStationMapper.stationID(for: city) else {
            print("No station ID found for city:", city)
            throw APIError.noData
        }
        let dto    = try await GeoMetService.shared.fetchCityWeatherItem(itemID: stationID)
        let mapped = GeoMetCityPageMapper.map(dto: dto, city: city)
        return mapped
    }

    func fetchWeather(for city: String, latitude: Double, longitude: Double) async throws -> CityWeather {
        return try await fetchWeather(for: city)
    }

    // Used by CityDeepDiveViewModel — merges GeoMet + Open-Meteo hourly
    func fetchWeatherFull(for city: String) async throws -> CityWeather {
        let base = try await fetchWeather(for: city)

        do {
            let (lat, lon)   = try await GeocodingService.shared.getCoordinates(for: city)
            let hourlyResult = try await OpenMeteoService.shared.fetchHourlyData(lat: lat, lon: lon)

            let enrichedFactors = enrichFactors(
                base:       base.factors,
                windspeed:  hourlyResult.currentWindspeed,
                precipProb: hourlyResult.currentPrecipProb
            )
            let enrichedScore = enrichScore(
                base:       base.stormRiskScore,
                windspeed:  hourlyResult.currentWindspeed,
                precipProb: hourlyResult.currentPrecipProb,
                hasAlerts:  !base.alerts.isEmpty
            )

            return CityWeather(
                city:           base.city,
                temperature:    base.temperature,
                condition:      base.condition,
                highLow:        base.highLow,
                hourly:         hourlyResult.forecasts,
                factors:        enrichedFactors,
                alerts:         base.alerts,
                stormRiskScore: enrichedScore,
                theme:          base.theme
            )
        } catch {
            print("Open-Meteo enrichment failed for \(city):", error.localizedDescription)
            return base
        }
    }

    private func enrichFactors(base: [StormFactor], windspeed: Double, precipProb: Int) -> [StormFactor] {
        var factors = base

        if windspeed > 15 {
            let sev: FactorSeverity = windspeed > 60 ? .severe : windspeed > 40 ? .high : windspeed > 25 ? .moderate : .low
            let entry = StormFactor(title: "Wind Speed", icon: "wind", value: "\(Int(windspeed)) km/h", severity: sev)
            if let idx = factors.firstIndex(where: { $0.title.lowercased().contains("wind") }) {
                factors[idx] = entry
            } else {
                factors.append(entry)
            }
        }

        if precipProb > 0 {
            let sev: FactorSeverity = precipProb > 70 ? .high : precipProb > 40 ? .moderate : .low
            let entry = StormFactor(title: "Precipitation", icon: "cloud.rain.fill", value: "\(precipProb)%", severity: sev)
            if let idx = factors.firstIndex(where: { $0.title.lowercased().contains("precip") }) {
                factors[idx] = entry
            } else if precipProb > 10 {
                factors.append(entry)
            }
        }

        if factors.count > 1, let clearIdx = factors.firstIndex(where: { $0.title == "Clear Conditions" }) {
            factors.remove(at: clearIdx)
        }

        return factors
    }

    private func enrichScore(base: Int, windspeed: Double, precipProb: Int, hasAlerts: Bool) -> Int {
        var score = base
        if windspeed > 60      { score += 15 }
        else if windspeed > 40 { score += 10 }
        else if windspeed > 25 { score += 5  }
        if precipProb > 70      { score += 12 }
        else if precipProb > 40 { score += 7  }
        if hasAlerts { score += 8 }
        return min(score, 100)
    }
}
