//
//  NotificationService.swift
//  G30-project
//
//  Created by Danuja Shankar on 2026-04-12.
//

import Foundation

final class NotificationService {
    static let shared = NotificationService()

    private let cityStorage = CityStorage()
    private let notificationStorage = NotificationStorage()

    private init() {}

    func refreshNotifications() async {
        let savedCities = cityStorage.fetchCities()

        for city in savedCities {
            do {
                guard let stationID = WeatherStationLocator.shared.nearestStation(
                    lat: city.latitude,
                    lon: city.longitude
                ) else {
                    continue
                }

                let dto = try await GeoMetService.shared.fetchCityWeatherItem(itemID: stationID)

                let warnings = dto.properties.warnings ?? []

                for warning in warnings {
                    let title = warning.description?.en ?? "Weather Warning"
                    let levelText = warning.alertColourLevel?.en?.lowercased() ?? "moderate"
                    let severity = mapSeverity(levelText)

                    let message = "\(title) for \(city.cityName)"
                    let key = "\(city.cityName)|\(title)|\(levelText)"

                    let notification = StormNotification(
                        id: 0,
                        city: city.cityName,
                        title: title,
                        message: message,
                        source: "Government of Canada",
                        severity: severity,
                        issuedAt: Date(),
                        notificationKey: key
                    )

                    let inserted = notificationStorage.insert(notification)

                    if inserted && !notificationStorage.wasDelivered(key: key) {
                        await AppNotificationManager.shared.sendLocalNotification(
                            title: "\(city.cityName): \(title)",
                            body: message,
                            identifier: key
                        )
                        notificationStorage.markDelivered(key: key)
                    }
                }
            } catch {
                print("Failed to refresh notifications for \(city.cityName): \(error.localizedDescription)")
            }
        }
    }

    func fetchStoredNotifications() -> [StormNotification] {
        notificationStorage.fetchAll()
    }

    private func mapSeverity(_ level: String) -> StormNotification.Severity {
        switch level {
        case let value where value.contains("red"):
            return .severe
        case let value where value.contains("orange"):
            return .high
        case let value where value.contains("yellow"):
            return .moderate
        default:
            return .low
        }
    }
}
