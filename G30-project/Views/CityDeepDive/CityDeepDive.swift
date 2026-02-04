import SwiftUI

struct CityDeepDive: View {
    let data: CityWeather

    var body: some View {
        ZStack {
            LinearGradient(
                colors: data.theme.gradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    headerCard
                    hourlyRow
                    riskFactors
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle(data.city)
        .navigationBarTitleDisplayMode(.inline)
    }


    private var headerCard: some View {
        VStack(spacing: 6) {
            Text(data.city)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.black.opacity(0.65))

            Text(data.condition)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.black.opacity(0.45))

            Text(data.temperature)
                .font(.system(size: 74, weight: .thin))
                .foregroundStyle(.black.opacity(0.80))
                .monospacedDigit()

            Text(data.highLow)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.black.opacity(0.45))
        }
        .padding(.top, 8)
    }

    private var hourlyRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hourly")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(data.hourly) { item in
                        HourChip(item: item)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var riskFactors: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Storm Risk Factors")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(data.factors) { f in
                    HStack(spacing: 12) {
                        Image(systemName: f.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 28)

                        Text(f.title)
                            .font(.system(size: 16, weight: .semibold))

                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HourChip: View {
    let item: HourlyForecast

    var body: some View {
        VStack(spacing: 8) {
            Text(item.time)
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.hierarchical)

            Text(item.temp)
                .font(.system(size: 16, weight: .semibold))
                .monospacedDigit()

            Text(item.precip)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 74, height: 110)
        .background(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.gray.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )

    }
}

#Preview {
    NavigationStack {
        CityDeepDive(data: .mockToronto)
    }
}
