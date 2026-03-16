import SwiftUI

struct CityRiskCardView: View {
    let temp: String
    let highLow: String
    let city: String
    let country: String
    let risk: String
    let symbol: String
    let onDelete: () -> Void

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

        
        .overlay(alignment: .topTrailing) {
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.black.opacity(0.35))
                    .clipShape(Circle())
            }
            .padding(10)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
