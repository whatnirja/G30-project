//
//  AppNotificationManager.swift
//  G30-project
//
//  Created by Danuja Shankar on 2026-04-12.
//

import Foundation
import UserNotifications

final class AppNotificationManager {
    static let shared = AppNotificationManager()

    private init() {}

    func requestPermission() async {
        do {
            let center = UNUserNotificationCenter.current()
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
        }
    }

    func sendLocalNotification(title: String, body: String, identifier: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule local notification: \(error.localizedDescription)")
        }
    }
}
