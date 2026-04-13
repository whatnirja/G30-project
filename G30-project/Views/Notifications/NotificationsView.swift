import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.96, blue: 0.99),
                    Color(red: 0.92, green: 0.94, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Group {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading alerts...")
                        .font(.headline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Alerts Yet",
                        systemImage: "bell.slash",
                        description: Text("Storm alerts and official warnings will appear here.")
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notifications")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))

                                Text("Live storm alerts for your saved cities")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                            ForEach(viewModel.items) { item in
                                NotificationCard(item: item)
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

private struct NotificationCard: View {
    let item: StormNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)

                Image(systemName: item.severity.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text(cleanedTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 8)

                    Text(item.formattedTime)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }

                Text(item.message)
                    .font(.subheadline)
                    .foregroundStyle(Color.primary.opacity(0.72))
                    .lineSpacing(2)

                HStack(spacing: 8) {
                    InfoPill(text: item.city, tint: .blue)
                    InfoPill(text: severityText, tint: severityPillColor)
                }

                Text(item.source)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 20)
    }

    private var cleanedTitle: String {
        item.title
            .replacingOccurrences(of: "WARNING - ", with: "")
            .replacingOccurrences(of: "WATCH - ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var severityText: String {
        switch item.severity {
        case .severe: return "Severe"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        }
    }

    private var iconColor: Color {
        switch item.severity {
        case .severe: return .red
        case .high: return .orange
        case .moderate: return Color(red: 0.88, green: 0.67, blue: 0.05)
        case .low: return .green
        }
    }

    private var iconBackgroundColor: Color {
        switch item.severity {
        case .severe: return .red.opacity(0.12)
        case .high: return .orange.opacity(0.12)
        case .moderate: return .yellow.opacity(0.16)
        case .low: return .green.opacity(0.12)
        }
    }

    private var severityPillColor: Color {
        switch item.severity {
        case .severe: return .red
        case .high: return .orange
        case .moderate: return .yellow
        case .low: return .green
        }
    }
}

private struct InfoPill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}
