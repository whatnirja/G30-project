//
//  NotificationStorage.swift
//  G30-project
//
//  Created by Danuja Shankar on 2026-04-12.
//

import Foundation
import SQLite3

final class NotificationStorage {
    private let db = SQLiteManager.shared.database

    func insert(_ notification: StormNotification) -> Bool {
        let query = """
        INSERT OR IGNORE INTO storm_notifications
        (city, title, message, source, severity, issued_at, notification_key)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        let issuedAt = ISO8601DateFormatter().string(from: notification.issuedAt)

        sqlite3_bind_text(statement, 1, (notification.city as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (notification.title as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (notification.message as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (notification.source as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (notification.severity.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (issuedAt as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 7, (notification.notificationKey as NSString).utf8String, -1, nil)

        let success = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return success
    }

    func fetchAll() -> [StormNotification] {
        let query = """
        SELECT id, city, title, message, source, severity, issued_at, notification_key
        FROM storm_notifications
        ORDER BY issued_at DESC;
        """

        var statement: OpaquePointer?
        var items: [StormNotification] = []

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let city = String(cString: sqlite3_column_text(statement, 1))
            let title = String(cString: sqlite3_column_text(statement, 2))
            let message = String(cString: sqlite3_column_text(statement, 3))
            let source = String(cString: sqlite3_column_text(statement, 4))
            let severityRaw = String(cString: sqlite3_column_text(statement, 5))
            let issuedAtRaw = String(cString: sqlite3_column_text(statement, 6))
            let notificationKey = String(cString: sqlite3_column_text(statement, 7))

            let severity = StormNotification.Severity(rawValue: severityRaw) ?? .moderate
            let issuedAt = ISO8601DateFormatter().date(from: issuedAtRaw) ?? Date()

            items.append(
                StormNotification(
                    id: id,
                    city: city,
                    title: title,
                    message: message,
                    source: source,
                    severity: severity,
                    issuedAt: issuedAt,
                    notificationKey: notificationKey
                )
            )
        }

        sqlite3_finalize(statement)
        return items
    }

    func wasDelivered(key: String) -> Bool {
        let query = "SELECT notification_key FROM delivered_notifications WHERE notification_key = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
        let exists = sqlite3_step(statement) == SQLITE_ROW
        sqlite3_finalize(statement)
        return exists
    }

    func markDelivered(key: String) {
        let query = """
        INSERT OR IGNORE INTO delivered_notifications
        (notification_key, delivered_at)
        VALUES (?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            return
        }

        let now = ISO8601DateFormatter().string(from: Date())

        sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (now as NSString).utf8String, -1, nil)

        _ = sqlite3_step(statement)
        sqlite3_finalize(statement)
    }
}
