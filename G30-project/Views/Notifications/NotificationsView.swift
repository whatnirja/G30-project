import SwiftUI

struct NotificationsView: View {
    private let items = MockNotifications.items

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(items) { item in
                        NotificationCard(item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }
}

private struct NotificationCard: View {
    let item: StormNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor)

            Text(item.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(2)

            Spacer(minLength: 8)

            Text(item.timeText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var iconColor: Color {
        switch item.level {
        case .severe: return .red
        case .high: return .orange
        case .moderate: return .yellow
        case .low: return .green
        }
    }
}
