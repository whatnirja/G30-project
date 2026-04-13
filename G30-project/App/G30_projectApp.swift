import SwiftUI

@main
struct G30_projectApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    await AppNotificationManager.shared.requestPermission()
                }
        }
    }
}
