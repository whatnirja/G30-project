import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.60, green: 0.85, blue: 1.0),
                    Color(red: 0.35, green: 0.65, blue: 0.95),
                    Color(red: 0.20, green: 0.50, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {

                // Logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    Image(systemName: "cloud.bolt.rain.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(.white)
                }

                // App Name
                Text("Storm Predictor")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)

                
                // Team Members
                VStack(spacing: 6) {
                    Text("Team Members:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 12)

                    Text("Nirja Arun Dabhi")
                    Text("Rishamnoor Kaur")
                    Text("Danuja Shankar")
                    Text("Gia Nagpal")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.92))
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
}

#Preview {
    SplashView()
}
