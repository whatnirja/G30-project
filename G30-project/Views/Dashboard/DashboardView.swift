import SwiftUI

struct DashboardView: View {
    @State private var searchText = ""

    private let items: [DashboardItem] = [
        .init(data: .mockToronto, riskLabel: "Moderate Risk", icon: "cloud.snow.fill"),
        .init(data: .mockLondon, riskLabel: "High Risk", icon: "cloud.heavyrain.fill"),
        .init(data: .mockWindsor, riskLabel: "Severe Risk", icon: "cloud.bolt.rain.fill")
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 14) {

                HStack(spacing: 12) {
                    Text("Weather")
                        .font(.system(size: 28, weight: .bold))

                    Spacer()

                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 38, height: 38)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)

                // MARK: Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search for a city or airport", text: $searchText)
                        .font(.system(size: 16, weight: .medium))

                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 18)

                // MARK: Cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(items) { item in
                            NavigationLink {
                                CityDeepDive(data: item.data)
                            } label: {
                                CityRiskCardView(
                                    temp: item.data.temperature,
                                    highLow: item.data.highLow,
                                    city: item.data.city,
                                    country: "Canada",
                                    risk: item.riskLabel,
                                    symbol: item.icon
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24) // no extra padding needed now
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Dashboard item wrapper
struct DashboardItem: Identifiable {
    let id = UUID()
    let data: CityWeather
    let riskLabel: String
    let icon: String
}

// MARK: - Card UI
struct CityRiskCardView: View {
    let temp: String
    let highLow: String
    let city: String
    let country: String
    let risk: String
    let symbol: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: "#132D78"))
                .frame(height: 160)
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 8)

            DiagonalOverlay()
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .frame(height: 160)
                .opacity(0.9)

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(temp)
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(.white)

                    Text(highLow)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))

                    Text("\(city), \(country)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.12))
                            .frame(width: 88, height: 88)

                        Image(systemName: symbol)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text(risk)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 18)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

// MARK: - Diagonal overlay
struct DiagonalOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                path.move(to: CGPoint(x: 0, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.20))
                path.addLine(to: CGPoint(x: w, y: h * 0.20))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.closeSubpath()
            }
            .fill(.white.opacity(0.10))
        }
    }
}

// MARK: - Hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xff, (int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
