import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Notifications")
                .font(.title2).bold()
            Text("Alert history goes here (placeholder)")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Notifications")
    }
}
