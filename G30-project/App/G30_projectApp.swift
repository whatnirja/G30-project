import SwiftUI

@main
struct G30_projectApp: App {

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .transition(.opacity)
                        .task {
                            await AppNotificationManager.shared.requestPermission()
                        }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showSplash = false
                }
            }
        }
    }
}
