import Foundation
import SQLite3

final class WeatherCacheStorage {
    private let db = SQLiteManager.shared.database

    func saveWeather(_ weather: CityWeather) -> Bool {
        let query = """
        INSERT OR REPLACE INTO weather_cache
        (city_name, temperature, condition, high_low, cached_at)
        VALUES (?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return false }

        let cachedAt = ISO8601DateFormatter().string(from: Date())
        sqlite3_bind_text(statement, 1, (weather.city        as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (weather.temperature as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (weather.condition   as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (weather.highLow     as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (cachedAt            as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    func fetchWeather(for cityName: String) -> CityWeather? {
        let query = """
        SELECT city_name, temperature, condition, high_low
        FROM weather_cache WHERE city_name = ?;
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(statement, 1, (cityName as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { sqlite3_finalize(statement); return nil }

        let city        = String(cString: sqlite3_column_text(statement, 0))
        let temperature = String(cString: sqlite3_column_text(statement, 1))
        let condition   = String(cString: sqlite3_column_text(statement, 2))
        let highLow     = String(cString: sqlite3_column_text(statement, 3))
        sqlite3_finalize(statement)

        return CityWeather(
            city:           city,
            country:        "Canada",
            latitude:       0.0,
            longitude:      0.0,
            temperature:    temperature,
            condition:      condition,
            highLow:        highLow,
            hourly:         [],
            factors:        GeoMetCityPageMapper.computeBasicFactors(from: condition),
            alerts:         [],
            stormRiskScore: GeoMetCityPageMapper.computeRiskScore(from: condition, alertCount: 0),
            theme:          themeFrom(condition: condition)
        )
    }

    func fetchAllCachedWeather() -> [CityWeather] {
        let query = """
        SELECT city_name, temperature, condition, high_low
        FROM weather_cache ORDER BY cached_at DESC;
        """
        var statement: OpaquePointer?
        var result: [CityWeather] = []
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return [] }

        while sqlite3_step(statement) == SQLITE_ROW {
            let city        = String(cString: sqlite3_column_text(statement, 0))
            let temperature = String(cString: sqlite3_column_text(statement, 1))
            let condition   = String(cString: sqlite3_column_text(statement, 2))
            let highLow     = String(cString: sqlite3_column_text(statement, 3))

            result.append(CityWeather(
                city:           city,
                country:        "Canada",
                latitude:       0.0,
                longitude:      0.0,
                temperature:    temperature,
                condition:      condition,
                highLow:        highLow,
                hourly:         [],
                factors:        GeoMetCityPageMapper.computeBasicFactors(from: condition),
                alerts:         [],
                stormRiskScore: GeoMetCityPageMapper.computeRiskScore(from: condition, alertCount: 0),
                theme:          themeFrom(condition: condition)
            ))
        }
        sqlite3_finalize(statement)
        return result
    }

    func deleteWeather(for city: String) -> Bool {
        let query = "DELETE FROM weather_cache WHERE city_name = ?;"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }
        sqlite3_bind_text(statement, 1, (city as NSString).utf8String, -1, nil)
        return sqlite3_step(statement) == SQLITE_DONE
    }

    private func themeFrom(condition: String) -> WeatherTheme {
        let lower = condition.lowercased()
        if lower.contains("thunder") || lower.contains("storm")                             { return .storm }
        if lower.contains("snow") || lower.contains("flurr") || lower.contains("ice")       { return .snowy }
        if lower.contains("rain") || lower.contains("drizzle") || lower.contains("shower")  { return .rainy }
        if lower.contains("wind")                                                            { return .windy }
        if lower.contains("cloud") || lower.contains("fog")                                 { return .cloudy }
        if lower.contains("sun") || lower.contains("clear")                                 { return .sunny }
        return .defaultTheme
    }
}
