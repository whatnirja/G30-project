//
//  SQLiteManager.swift
//  G30-project
//
//  Created by Gia Nagpal on 2026-03-13.
//
import Foundation
import SQLite3

final class SQLiteManager {
    static let shared = SQLiteManager()

    private var db: OpaquePointer?
    

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    var database: OpaquePointer? {
        db
    }

    private func openDatabase() {
        do {
            let documentsURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let dbURL = documentsURL.appendingPathComponent("storm_predictor.sqlite")

            if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
                print("Failed to open database")
            } else {
                print("Database opened at: \(dbURL.path)")
            }
        } catch {
            print("Failed to locate documents directory: \(error)")
        }
    }

    private func createTables() {
        let createSavedCitiesTable = """
        CREATE TABLE IF NOT EXISTS saved_cities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city_name TEXT NOT NULL,
            province TEXT NOT NULL,
            country TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(city_name, province)
        );
        """

        let createWeatherCacheTable = """
        CREATE TABLE IF NOT EXISTS weather_cache (
            city_name TEXT PRIMARY KEY,
            temperature TEXT NOT NULL,
            condition TEXT NOT NULL,
            high_low TEXT NOT NULL,
            cached_at TEXT NOT NULL
        );
        """

        execute(createSavedCitiesTable)
        execute(createWeatherCacheTable)
    }

    private func execute(_ query: String) {
        var errorMessage: UnsafeMutablePointer<Int8>?

        if sqlite3_exec(db, query, nil, nil, &errorMessage) != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Unknown SQL error"
            print("SQL error: \(message)")
        }
    }
}
