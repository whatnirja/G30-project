import SwiftUI

struct DashboardView: View{
    var body: some View {
        VStack(spacing: 12) {
            Text("Dashboard")
                .font(.title2).bold()
            Text("Multi-city list")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Weather")
    }
}
