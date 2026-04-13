import SwiftUI

struct AppTabView: View {
    @State private var selectedTab: Tab = .dashboard

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .dashboard:
                    NavigationStack {
                        DashboardView()
                    }

                case .map:
                    NavigationStack {
                        OntarioMapView()
                    }

                case .alerts:
                    NavigationStack {
                        NotificationsView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.white.ignoresSafeArea())
    }
}

enum Tab {
    case dashboard
    case map
    case alerts
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(
                tab: .dashboard,
                title: "Dashboard",
                icon: "house.fill"
            )

            Spacer(minLength: 0)

            tabButton(
                tab: .map,
                title: "Map",
                icon: "map.fill"
            )

            Spacer(minLength: 0)

            tabButton(
                tab: .alerts,
                title: "Alerts",
                icon: "bell.fill"
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(height: 82)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 8)
    }

    @ViewBuilder
    private func tabButton(tab: Tab, title: String, icon: String) -> some View {
        let isSelected = selectedTab == tab

        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))

                if isSelected {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .foregroundStyle(isSelected ? Color.black.opacity(0.85) : Color.black.opacity(0.55))
            .frame(height: 56)
            .padding(.horizontal, isSelected ? 22 : 18)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.55))
                    } else {
                        Color.clear
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AppTabView()
}
