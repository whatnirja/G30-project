import SwiftUI

struct SplashView: View {
    @State private var goNext = false

    var body: some View {
        Group {
            if goNext {
                // This is your "Home" after splash.
                // If your app uses AppTabView as home, keep it like this:
                AppTabView()
            } else {
                splashUI
            }
        }
        .onAppear {
            // 2.3 seconds = similar to 2–3 seconds in the PDF
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                withAnimation(.easeInOut) {
                    goNext = true
                }
            }
        }
    }

    private var splashUI: some View {
        VStack(spacing: 16) {
            Spacer()

            // Logo (uses Assets image "storm_logo" if available)
            if let _ = UIImage(named: "storm_logo") {
                Image("storm_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
            } else {
                // fallback if you didn’t add the asset yet
                Image(systemName: "cloud.bolt.rain.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.blue)
            }

            Text("Storm Predictor")
                .font(.system(size: 28, weight: .semibold))

            Text("Loading...")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 6) {
                Text("Team G30:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 2) {
                    Text("Rishamnoor Kaur")
                    Text("Danuja Shankar")
                    Text("Nirja Arun Dabhi")
                    Text("Gia Nagpal")
                }
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
