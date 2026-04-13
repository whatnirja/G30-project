import SwiftUI

struct CityDeepDive: View {
    @StateObject private var viewModel: CityDeepDiveViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: CityWeather) {
        _viewModel = StateObject(wrappedValue: CityDeepDiveViewModel(initialData: data))
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroWeatherSection
                    stormRiskIndexSection
                    riskFactorsSection
                    if !viewModel.weather.alerts.isEmpty {
                        activeAlertsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 100)
            }

            if viewModel.isLoading {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ProgressView().tint(.black.opacity(0.5))
                        Text("Updating…")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 110)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.all, edges: .bottom)
        .background(Color.white)
        .task { await viewModel.fetchFreshData() }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, viewModel.weather.theme.gradient.last?.opacity(0.10) ?? Color.white],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                ZStack {
                    Circle()
                        .fill(viewModel.weather.theme.gradient.first?.opacity(0.85) ?? Color.orange.opacity(0.7))
                        .frame(width: 420, height: 420).blur(radius: 90).offset(x: -40, y: 90)
                    Circle()
                        .fill(viewModel.weather.theme.gradient.last?.opacity(0.80) ?? Color.yellow.opacity(0.6))
                        .frame(width: 380, height: 380).blur(radius: 100).offset(x: 90, y: 130)
                }
                .frame(maxWidth: .infinity).frame(height: 420)
                Spacer()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.clear, Color.white.opacity(0.35), Color.white.opacity(0.85)],
                startPoint: .center, endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var heroWeatherSection: some View {
        VStack(spacing: 0) {
            topBar.padding(.top, 10)
            Spacer(minLength: 120)
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 6) {
                        Text(cleanTemperature(viewModel.weather.temperature))
                            .font(.system(size: 86, weight: .light, design: .rounded))
                            .foregroundStyle(.black.opacity(0.88))
                            .monospacedDigit()
                        Text("°C")
                            .font(.system(size: 34, weight: .light))
                            .foregroundStyle(.black.opacity(0.70))
                            .padding(.bottom, 12)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        highLowRow(symbol: "arrow.up",   value: extractHighLow(viewModel.weather.highLow).high)
                        highLowRow(symbol: "arrow.down", value: extractHighLow(viewModel.weather.highLow).low)
                    }
                    .padding(.bottom, 12)
                }

                Rectangle().fill(Color.black.opacity(0.75)).frame(height: 2)

                Text(viewModel.weather.condition)
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.82))
                    .lineLimit(2)
                    .padding(.horizontal)

                if !viewModel.weather.hourly.isEmpty {
                    hourlyTicker.padding(.top, 18).padding(.horizontal)
                } else {
                    Text("Loading hourly forecast…")
                        .font(.system(size: 13))
                        .foregroundStyle(.black.opacity(0.35))
                        .padding(.top, 18).padding(.horizontal)
                }
            }
        }
        .frame(minHeight: 720, alignment: .top)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.80))
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDateTime())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.black.opacity(0.45))
                Text(viewModel.weather.city)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.80))
            }
            .padding(.leading, 6)
            Spacer()
        }
    }

    private var hourlyTicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 18) {
                ForEach(viewModel.weather.hourly) { item in MinimalHourItem(item: item) }
            }
            .padding(.vertical, 2)
        }
    }

    private var stormRiskIndexSection: some View {
        glassCard {
            VStack(spacing: 20) {
                HStack {
                    Text("Storm Risk Index")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.82))
                    Spacer()
                    Text("Ontario-wide scale")
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.35))
                }

                HStack(spacing: 32) {
                    StormRiskGauge(score: viewModel.weather.stormRiskScore)

                    VStack(alignment: .leading, spacing: 12) {
                        riskLegendRow(color: .green,                                     label: "Low",      range: "0–25")
                        riskLegendRow(color: Color(red: 0.95, green: 0.75, blue: 0.10),  label: "Moderate", range: "26–50")
                        riskLegendRow(color: .orange,                                    label: "High",     range: "51–75")
                        riskLegendRow(color: .red,                                       label: "Severe",   range: "76–100")
                    }
                    Spacer()
                }
            }
            .padding(20)
        }
    }

    private func riskLegendRow(color: Color, label: String, range: String) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label).font(.system(size: 13, weight: .medium)).foregroundStyle(.black.opacity(0.72))
            Text(range).font(.system(size: 11)).foregroundStyle(.black.opacity(0.38))
        }
    }

    private var riskFactorsSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Storm Risk Factors")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.82))

                VStack(spacing: 10) {
                    ForEach(viewModel.weather.factors) { factor in factorCard(factor) }
                }
            }
            .padding(20)
        }
    }

    private func factorCard(_ factor: StormFactor) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(factor.severity.color.opacity(0.15))
                Image(systemName: factor.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(factor.severity.color)
            }
            .frame(width: 46, height: 46)

            Text(factor.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.82))
            Spacer()
            Text(factor.value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(factor.severity.color)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.45))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(factor.severity.color.opacity(0.25), lineWidth: 1)
        )
    }

    private var activeAlertsSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                    Text("Active Alerts")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.82))
                }
                VStack(spacing: 10) {
                    ForEach(viewModel.weather.alerts, id: \.self) { alert in alertRow(alert) }
                }
            }
            .padding(20)
        }
    }

    private func alertRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color.red).frame(width: 8, height: 8).padding(.top, 5)
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.black.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.red.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.red.opacity(0.18), lineWidth: 1))
    }

    @ViewBuilder
    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.48))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.40), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }


    private func highLowRow(symbol: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold)).foregroundStyle(.black.opacity(0.65))
            Text(value)
                .font(.system(size: 16, weight: .medium)).foregroundStyle(.black.opacity(0.72)).monospacedDigit()
        }
    }

    private func cleanTemperature(_ value: String) -> String {
        value.replacingOccurrences(of: "°C", with: "").replacingOccurrences(of: "°", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractHighLow(_ text: String) -> (high: String, low: String) {
        let stripped = text
            .replacingOccurrences(of: "H:", with: "").replacingOccurrences(of: "L:", with: "")
            .replacingOccurrences(of: "/",  with: " ").replacingOccurrences(of: "|",  with: " ")
        let parts = stripped.split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return parts.count >= 2 ? (parts[0], parts[1]) : ("--", "--")
    }

    private func formattedDateTime() -> String {
        let f = DateFormatter(); f.dateFormat = "h:mm a, EEE MMM d"; return f.string(from: Date())
    }
}


private struct StormRiskGauge: View {
    let score: Int

    private var gaugeColor: Color {
        switch score {
        case 0...25:  return .green
        case 26...50: return Color(red: 0.95, green: 0.75, blue: 0.10)
        case 51...75: return .orange
        default:      return .red
        }
    }

    private var riskLabel: String {
        switch score {
        case 0...25:  return "LOW RISK"
        case 26...50: return "MODERATE"
        case 51...75: return "HIGH RISK"
        default:      return "SEVERE"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.gray.opacity(0.18), style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(135))

            Circle()
                .trim(from: 0, to: max(0.01, 0.75 * Double(score) / 100.0))
                .stroke(gaugeColor, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(135))
                .animation(.easeOut(duration: 1.2), value: score)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.88))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(riskLabel)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(gaugeColor)
                    .tracking(0.8)
            }
        }
        .frame(width: 140, height: 140)
    }
}


private struct MinimalHourItem: View {
    let item: HourlyForecast
    var body: some View {
        VStack(spacing: 6) {
            Text(item.temp).font(.system(size: 12, weight: .medium)).foregroundStyle(.black.opacity(0.70)).monospacedDigit()
            Image(systemName: item.icon).font(.system(size: 17, weight: .regular)).foregroundStyle(.black.opacity(0.72))
            Text(item.time).font(.system(size: 10, weight: .regular)).foregroundStyle(.black.opacity(0.45))
        }
        .frame(minWidth: 34)
    }
}


#Preview {
    NavigationStack { CityDeepDive(data: .mockToronto) }
}
