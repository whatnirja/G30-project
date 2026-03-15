import SwiftUI

struct CityDeepDive: View {
    let data: CityWeather
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroWeatherSection
                    riskSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 32)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
            .ignoresSafeArea(.all, edges: .bottom)
            .background(Color.white)
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    data.theme.gradient.last?.opacity(0.10) ?? Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                ZStack {
                    Circle()
                        .fill(data.theme.gradient.first?.opacity(0.85) ?? Color.orange.opacity(0.7))
                        .frame(width: 420, height: 420)
                        .blur(radius: 90)
                        .offset(x: -40, y: 90)

                    Circle()
                        .fill(data.theme.gradient.last?.opacity(0.80) ?? Color.yellow.opacity(0.6))
                        .frame(width: 380, height: 380)
                        .blur(radius: 100)
                        .offset(x: 90, y: 130)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 420)

                Spacer()
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.85)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var heroWeatherSection: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.top, 10)

            Spacer(minLength: 120)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 6) {
                        Text(cleanTemperatureValue(data.temperature))
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
                        highLowRow(
                            symbol: "arrow.up",
                            value: extractHighLowValues(from: data.highLow).high
                        )

                        highLowRow(
                            symbol: "arrow.down",
                            value: extractHighLowValues(from: data.highLow).low
                        )
                    }
                    .padding(.bottom, 12)
                }

                Rectangle()
                    .fill(Color.black.opacity(0.75))
                    .frame(height: 2)

                Text(data.condition)
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.82))
                    .lineLimit(2)
                    .padding(.horizontal)

                hourlyTicker
                    .padding(.top, 18)
                    .padding(.horizontal)
            }
        }
        .frame(minHeight: 720, alignment: .top)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.80))
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDateTime())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.black.opacity(0.45))

                Text(data.city)
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
                ForEach(data.hourly) { item in
                    MinimalHourItem(item: item)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var riskSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Storm Risk Factors")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.black.opacity(0.82))
                .padding()

            VStack(spacing: 12) {
                ForEach(data.factors) { factor in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.55))

                            Image(systemName: factor.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.black.opacity(0.78))
                        }
                        .frame(width: 48, height: 48)

                        Text(factor.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.black.opacity(0.82))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.35))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white.opacity(0.48))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func highLowRow(symbol: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.black.opacity(0.65))

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.black.opacity(0.72))
                .monospacedDigit()
        }
    }

    private func cleanTemperatureValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "°C", with: "")
            .replacingOccurrences(of: "°", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractHighLowValues(from text: String) -> (high: String, low: String) {
        let stripped = text.replacingOccurrences(of: "H:", with: "")
            .replacingOccurrences(of: "L:", with: "")
            .replacingOccurrences(of: "High:", with: "")
            .replacingOccurrences(of: "Low:", with: "")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "|", with: " ")

        let parts = stripped
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if parts.count >= 2 {
            return (parts[0], parts[1])
        }

        return ("--", "--")
    }

    private func formattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a, EEE MMM d"
        return formatter.string(from: Date())
    }
}

private struct MinimalHourItem: View {
    let item: HourlyForecast

    var body: some View {
        VStack(spacing: 6) {
            Text(item.temp)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.black.opacity(0.70))
                .monospacedDigit()

            Image(systemName: item.icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.black.opacity(0.72))

            Text(item.time)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.black.opacity(0.45))
        }
        .frame(minWidth: 34)
    }
}

#Preview {
    NavigationStack {
        CityDeepDive(data: .mockToronto)
    }
}
