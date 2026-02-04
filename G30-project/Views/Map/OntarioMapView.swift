import SwiftUI

struct OntarioMapView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Map Overview")
                .font(.title2).bold()
            Text("Ontario risk map")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Map")
    }
}
