import SwiftUI
import MapKit

enum StormSeverity: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"

    var fillAlpha: CGFloat { 0.28 }
    var strokeAlpha: CGFloat { 0.75 }
}

// Extension of weather UI theme for Map Screen
extension StormSeverity {
    var theme: WeatherTheme {
        switch self {
        case .low: return .sunny
        case .moderate: return .cloudy
        case .high: return .rainy
        case .severe: return .storm
        }
    }
}

struct RiskRegion: Identifiable, Hashable {
    let id: String
    let name: String
    let severity: StormSeverity
    let summary: String
    let polygonCoords: [CLLocationCoordinate2D]

    static func == (lhs: RiskRegion, rhs: RiskRegion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum OntarioMockData {
    static let ontarioCenter = CLLocationCoordinate2D(latitude: 50.0, longitude: -85.0)

    static let regions: [RiskRegion] = [
        makeRegion(from: .mockToronto),
        makeRegion(from: .mockLondon),
        makeRegion(from: .mockWindsor)
    ]


    private static func makeRegion(from weather: CityWeather) -> RiskRegion {
        let (id, polygon) = regionGeometry(for: weather.city)

        return RiskRegion(
            id: id,
            name: weather.city,
            severity: severity(from: weather.theme, condition: weather.condition),
            summary: summary(from: weather),
            polygonCoords: polygon
        )
    }

    private static func summary(from weather: CityWeather) -> String {
        "\(weather.condition) · \(weather.highLow)"
    }

    private static func severity(from theme: WeatherTheme, condition: String) -> StormSeverity {
        let lc = condition.lowercased()
        if lc.contains("storm") || lc.contains("lightning") { return .severe }
        if lc.contains("heavy") { return .high }

        switch theme {
        case .sunny:
            return .low
        case .cloudy:
            return .moderate
        case .rainy:
            return .high
        case .storm:
            return .severe
        default:
            return .moderate
        }
    }

    
    private static func regionGeometry(for city: String) -> (id: String, polygon: [CLLocationCoordinate2D]) {
        switch city.lowercased() {
        case "toronto":
            return (
                "toronto",
                [
                    .init(latitude: 44.15, longitude: -80.10),
                    .init(latitude: 43.15, longitude: -80.10),
                    .init(latitude: 43.15, longitude: -78.80),
                    .init(latitude: 44.15, longitude: -78.80)
                ]
            )

        case "london":
            return (
                "london",
                [
                    .init(latitude: 43.20, longitude: -81.60),
                    .init(latitude: 42.70, longitude: -81.60),
                    .init(latitude: 42.70, longitude: -80.90),
                    .init(latitude: 43.20, longitude: -80.90)
                ]
            )

        case "windsor":
            return (
                "windsor",
                [
                    .init(latitude: 42.55, longitude: -83.35),
                    .init(latitude: 42.10, longitude: -83.35),
                    .init(latitude: 42.10, longitude: -82.65),
                    .init(latitude: 42.55, longitude: -82.65)
                ]
            )

        default:
            return (
                city.lowercased().replacingOccurrences(of: " ", with: "-"),
                [
                    .init(latitude: ontarioCenter.latitude + 0.7, longitude: ontarioCenter.longitude - 0.7),
                    .init(latitude: ontarioCenter.latitude - 0.7, longitude: ontarioCenter.longitude - 0.7),
                    .init(latitude: ontarioCenter.latitude - 0.7, longitude: ontarioCenter.longitude + 0.7),
                    .init(latitude: ontarioCenter.latitude + 0.7, longitude: ontarioCenter.longitude + 0.7)
                ]
            )
        }
    }
}

struct LegendPill: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

struct RiskRegionDetailSheet: View {
    let region: RiskRegion

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(region.name).font(.title2).bold()
                Text("Severity: \(region.severity.rawValue)").font(.headline)
                Text(region.summary).font(.body)
                Spacer()
            }
            .padding()
            .navigationTitle("Region Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OntarioMapView: View {
    @State private var selectedRegion: RiskRegion?
    @State private var showDetail = false

    @State private var mapRegion = MKCoordinateRegion(
        center: OntarioMockData.ontarioCenter,
        span: MKCoordinateSpan(latitudeDelta: 12.5, longitudeDelta: 18.0)
    )

    private var currentTheme: WeatherTheme {
        selectedRegion?.severity.theme ?? .defaultTheme
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: currentTheme.gradient, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            OntarioRiskMapRepresentable(
                region: $mapRegion,
                riskRegions: OntarioMockData.regions,
                onSelect: { rr in
                    selectedRegion = rr
                    showDetail = true
                }
            )
            .ignoresSafeArea()

            legend
                .padding(.top, 12)
        }
        .sheet(isPresented: $showDetail) {
            if let selectedRegion {
                RiskRegionDetailSheet(region: selectedRegion)
            }
        }
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ontario Storm Risk")
                .font(.headline)

            HStack(spacing: 10) {
                LegendPill(label: "Low")
                LegendPill(label: "Moderate")
                LegendPill(label: "High")
                LegendPill(label: "Severe")
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 14)
    }
}

struct OntarioRiskMapRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let riskRegions: [RiskRegion]
    let onSelect: (RiskRegion) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsCompass = true
        map.isRotateEnabled = false

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tap.cancelsTouchesInView = false
        map.addGestureRecognizer(tap)

        context.coordinator.applyOverlays(on: map, riskRegions: riskRegions)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        if map.region.center.latitude != region.center.latitude ||
            map.region.center.longitude != region.center.longitude {
            map.setRegion(region, animated: true)
        }

        let sw = CLLocationCoordinate2D(latitude: 41.5, longitude: -95.5)
        let ne = CLLocationCoordinate2D(latitude: 56.9, longitude: -74.0)

        let swPoint = MKMapPoint(sw)
        let nePoint = MKMapPoint(ne)

        let bounds = MKMapRect(
            x: min(swPoint.x, nePoint.x),
            y: min(swPoint.y, nePoint.y),
            width: abs(nePoint.x - swPoint.x),
            height: abs(nePoint.y - swPoint.y)
        )

        map.setCameraBoundary(MKMapView.CameraBoundary(mapRect: bounds), animated: false)

        context.coordinator.applyOverlays(on: map, riskRegions: riskRegions)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        private let onSelect: (RiskRegion) -> Void
        private var overlayIdToRegion: [ObjectIdentifier: RiskRegion] = [:]

        init(onSelect: @escaping (RiskRegion) -> Void) {
            self.onSelect = onSelect
        }

        func applyOverlays(on map: MKMapView, riskRegions: [RiskRegion]) {
            if map.overlays.count == riskRegions.count { return }
            map.removeOverlays(map.overlays)
            overlayIdToRegion.removeAll()

            for rr in riskRegions {
                let polygon = MKPolygon(coordinates: rr.polygonCoords, count: rr.polygonCoords.count)
                overlayIdToRegion[ObjectIdentifier(polygon)] = rr
                map.addOverlay(polygon)
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polygon = overlay as? MKPolygon else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolygonRenderer(polygon: polygon)

            if let rr = overlayIdToRegion[ObjectIdentifier(polygon)] {
                let color: UIColor
                switch rr.severity {
                case .low: color = .systemGreen
                case .moderate: color = .systemYellow
                case .high: color = .systemOrange
                case .severe: color = .systemRed
                }

                renderer.fillColor = color.withAlphaComponent(rr.severity.fillAlpha)
                renderer.strokeColor = color.withAlphaComponent(rr.severity.strokeAlpha)
                renderer.lineWidth = 2.0
            }

            return renderer
        }

        @objc func handleMapTap(_ recognizer: UITapGestureRecognizer) {
            guard let mapView = recognizer.view as? MKMapView else { return }
            let tapPoint = recognizer.location(in: mapView)

            for overlay in mapView.overlays {
                guard let polygon = overlay as? MKPolygon,
                      let rr = overlayIdToRegion[ObjectIdentifier(polygon)],
                      let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer
                else { continue }

                if renderer.path == nil {
                    renderer.createPath()
                }
                guard let path = renderer.path else { continue }

                let mapPoint = MKMapPoint(mapView.convert(tapPoint, toCoordinateFrom: mapView))
                let rendererPoint = renderer.point(for: mapPoint)

                if path.contains(rendererPoint) {
                    onSelect(rr)
                    return
                }
            }
        }
    }
}

#Preview {
    OntarioMapView()
}