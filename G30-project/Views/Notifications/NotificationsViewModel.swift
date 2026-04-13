//
//  NotificationsViewModel.swift
//  G30-project
//
//  Created by Danuja Shankar on 2026-04-12.
//

import Foundation
import Combine

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var items: [StormNotification] = []
    @Published var isLoading = false

    func load() async {
        isLoading = true
        await NotificationService.shared.refreshNotifications()
        items = NotificationService.shared.fetchStoredNotifications()
        isLoading = false
    }
}
