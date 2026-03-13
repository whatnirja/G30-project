//
//  CityStorage.swift
//  G30-project
//
//  Created by Gia Nagpal on 2026-03-13.
//

import Foundation
import SQLite3

final class CityStorage {
    private let db = SQLiteManager.shared.database

    func insertCity(
        cityName: String,
        province: String = "Ontario",
        country: String = "Canada",
        latitude: Double,
        longitude: Double
    ) -> Bool {
        let query = """
        INSERT OR IGNORE INTO saved_cities
        (city_name, province, country, latitude, longitude, created_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        let createdAt = ISO8601DateFormatter().string(from: Date())

        sqlite3_bind_text(statement, 1, (cityName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (province as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (country as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 4, latitude)
        sqlite3_bind_double(statement, 5, longitude)
        sqlite3_bind_text(statement, 6, (createdAt as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    func fetchCities() -> [SavedCity] {
        let query = """
        SELECT id, city_name, province, country, latitude, longitude, created_at
        FROM saved_cities
        ORDER BY created_at DESC;
        """

        var statement: OpaquePointer?
        var cities: [SavedCity] = []

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let cityName = String(cString: sqlite3_column_text(statement, 1))
            let province = String(cString: sqlite3_column_text(statement, 2))
            let country = String(cString: sqlite3_column_text(statement, 3))
            let latitude = sqlite3_column_double(statement, 4)
            let longitude = sqlite3_column_double(statement, 5)
            let createdAt = String(cString: sqlite3_column_text(statement, 6))

            cities.append(
                SavedCity(
                    id: id,
                    cityName: cityName,
                    province: province,
                    country: country,
                    latitude: latitude,
                    longitude: longitude,
                    createdAt: createdAt
                )
            )
        }

        sqlite3_finalize(statement)
        return cities
    }

    func deleteCity(cityName: String) -> Bool {
        let query = "DELETE FROM saved_cities WHERE city_name = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(statement, 1, (cityName as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }
}
