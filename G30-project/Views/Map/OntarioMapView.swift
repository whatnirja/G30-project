import SwiftUI
import MapKit

enum StormSeverity: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case severe = "Severe"

    var fillAlpha: CGFloat {
        switch self {
        case .low:      return 0.35
        case .moderate: return 0.42
        case .high:     return 0.52
        case .severe:   return 0.62
        }
    }

    var strokeAlpha: CGFloat {
        switch self {
        case .low:      return 0.70
        case .moderate: return 0.82
        case .high:     return 0.92
        case .severe:   return 1.00
        }
    }

    var glowLayers: Int {
        switch self {
        case .low:      return 1
        case .moderate: return 2
        case .high:     return 3
        case .severe:   return 4
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .low:      return 1.0
        case .moderate: return 1.4
        case .high:     return 1.8
        case .severe:   return 2.2
        }
    }
}

extension StormSeverity {
    var theme: WeatherTheme {
        switch self {
        case .low:      return .sunny
        case .moderate: return .cloudy
        case .high:     return .rainy
        case .severe:   return .storm
        }
    }

    var primaryUIColor: UIColor {
        switch self {
        case .low:
            return UIColor(red: 0.92, green: 0.68, blue: 0.05, alpha: 1)
        case .moderate:
            return UIColor(red: 0.45, green: 0.52, blue: 0.60, alpha: 1)
        case .high:
            return UIColor(red: 0.12, green: 0.38, blue: 0.88, alpha: 1)
        case .severe:
            return UIColor(red: 0.14, green: 0.11, blue: 0.36, alpha: 1)
        }
    }

    var secondaryUIColor: UIColor {
        switch self {
        case .low:
            return UIColor(red: 0.95, green: 0.48, blue: 0.08, alpha: 1)
        case .moderate:
            return UIColor(red: 0.28, green: 0.32, blue: 0.38, alpha: 1)
        case .high:
            return UIColor(red: 0.22, green: 0.14, blue: 0.72, alpha: 1)
        case .severe:
            return UIColor(red: 0.05, green: 0.18, blue: 0.58, alpha: 1)
        }
    }
}


struct RiskRegion: Identifiable, Hashable {
    let id: String
    let name: String
    let severity: StormSeverity
    let summary: String
    let center: CLLocationCoordinate2D
    let radiusMeters: CLLocationDistance
    let weather: CityWeather

    static func == (lhs: RiskRegion, rhs: RiskRegion) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}


enum RiskRegionMapper {
    static let ontarioCenter = CLLocationCoordinate2D(latitude: 50.0, longitude: -85.0)

    static func makeRegions(from weatherItems: [CityWeather]) -> [RiskRegion] {
        weatherItems.map { makeRegion(from: $0) }
    }

    static func makeRegion(from weather: CityWeather) -> RiskRegion {
        RiskRegion(
            id: weather.city.lowercased().replacingOccurrences(of: " ", with: "-"),
            name: weather.city,
            severity: severity(from: weather.theme, condition: weather.condition),
            summary: "\(weather.condition) · \(weather.highLow)",
            center: CLLocationCoordinate2D(latitude: weather.latitude, longitude: weather.longitude),
            radiusMeters: radius(for: weather.theme, condition: weather.condition),
            weather: weather
        )
    }

    static func severity(from theme: WeatherTheme, condition: String) -> StormSeverity {
        let lc = condition.lowercased()

        if lc.contains("storm") || lc.contains("lightning") || lc.contains("thunder") {
            return .severe
        }

        if lc.contains("heavy") || lc.contains("rain") {
            return .high
        }

        switch theme {
        case .sunny:
            return .low
        case .cloudy:
            return .moderate
        case .rainy:
            return .high
        case .storm:
            return .severe
        case .snowy:
            return .moderate
        case .windy:
            return .moderate
        case .defaultTheme:
            return .moderate
        }
    }

    static func radius(for theme: WeatherTheme, condition: String) -> CLLocationDistance {
        let lc = condition.lowercased()

        if lc.contains("storm") || lc.contains("lightning") || lc.contains("thunder") {
            return 70000
        }
        if lc.contains("heavy") || lc.contains("rain") {
            return 55000
        }

        switch theme {
        case .sunny:
            return 30000
        case .cloudy:
            return 40000
        case .rainy:
            return 55000
        case .storm:
            return 70000
        case .snowy:
            return 50000
        case .windy:
            return 45000
        case .defaultTheme:
            return 40000
        }
    }
}


struct LegendItem: View {
    let severity: StormSeverity

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(uiColor: severity.primaryUIColor),
                            Color(uiColor: severity.secondaryUIColor)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                )
                .shadow(color: Color(uiColor: severity.secondaryUIColor).opacity(0.35), radius: 4)

            Text(severity.rawValue)
                .font(.caption2)
                .foregroundStyle(.primary)
        }
    }
}

struct LegendCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ontario Storm Risk")
                .font(.headline)

            HStack(spacing: 12) {
                LegendItem(severity: .low)
                LegendItem(severity: .moderate)
                LegendItem(severity: .high)
                LegendItem(severity: .severe)
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 14)
    }
}


struct OntarioMapView: View {
    @State private var selectedRegion: RiskRegion?
    @State private var navigateToDeepDive = false
    @State private var riskRegions: [RiskRegion] = []

    @State private var mapRegion = MKCoordinateRegion(
        center: RiskRegionMapper.ontarioCenter,
        span: MKCoordinateSpan(latitudeDelta: 12.5, longitudeDelta: 18.0)
    )

    private let cityStorage = CityStorage()
    private let weatherCacheStorage = WeatherCacheStorage()

    private var currentTheme: WeatherTheme {
        selectedRegion?.severity.theme ?? .defaultTheme
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(colors: currentTheme.gradient, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                OntarioRiskMapRepresentable(
                    region: $mapRegion,
                    riskRegions: riskRegions,
                    onSelect: { rr in
                        selectedRegion = rr
                        navigateToDeepDive = true
                    }
                )
                .ignoresSafeArea()

                LegendCard()
                    .padding(.top, 12)

                if let selectedRegion {
                    VStack {
                        Spacer()

                        Button {
                            navigateToDeepDive = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedRegion.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(selectedRegion.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 18)
                        }
                    }
                }

                NavigationLink(
                    destination: Group {
                        if let selectedRegion {
                            CityDeepDive(data: selectedRegion.weather)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: $navigateToDeepDive
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .task {
                loadRealRegions()
            }
        }
    }

    private func loadRealRegions() {
        let savedCities = cityStorage.fetchCities()

        let weatherItems: [CityWeather] = savedCities.compactMap { savedCity -> CityWeather? in
            guard let cached = weatherCacheStorage.fetchWeather(for: savedCity.cityName) else {
                return nil
            }

            return CityWeather(
                city:           savedCity.cityName,
                country:        savedCity.country,
                latitude:       savedCity.latitude,
                longitude:      savedCity.longitude,
                temperature:    cached.temperature,
                condition:      cached.condition,
                highLow:        cached.highLow,
                hourly:         cached.hourly,
                factors:        cached.factors,
                alerts:         cached.alerts,
                stormRiskScore: cached.stormRiskScore,
                theme:          cached.theme
            )
        }

        let mappedRegions = RiskRegionMapper.makeRegions(from: weatherItems)
        riskRegions = mappedRegions

        if !mappedRegions.isEmpty {
            updateMapRegionToFitRegions(mappedRegions)
        }
    }

    private func updateMapRegionToFitRegions(_ regions: [RiskRegion]) {
        let allCoords = regions.map(\.center)
        guard !allCoords.isEmpty else { return }

        let minLat = allCoords.map(\.latitude).min() ?? RiskRegionMapper.ontarioCenter.latitude
        let maxLat = allCoords.map(\.latitude).max() ?? RiskRegionMapper.ontarioCenter.latitude
        let minLon = allCoords.map(\.longitude).min() ?? RiskRegionMapper.ontarioCenter.longitude
        let maxLon = allCoords.map(\.longitude).max() ?? RiskRegionMapper.ontarioCenter.longitude

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) + 3.0, 6.0),
            longitudeDelta: max((maxLon - minLon) + 3.0, 6.0)
        )

        mapRegion = MKCoordinateRegion(center: center, span: span)
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

        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMapTap(_:))
        )
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

        init(onSelect: @escaping (RiskRegion) -> Void) {
            self.onSelect = onSelect
        }

        func applyOverlays(on map: MKMapView, riskRegions: [RiskRegion]) {
            let expected = riskRegions.reduce(0) { $0 + 1 + $1.severity.glowLayers }
            if map.overlays.count == expected { return }

            map.removeOverlays(map.overlays)

            for rr in riskRegions {
                for layer in 1...rr.severity.glowLayers {
                    let expandedRadius = rr.radiusMeters + (Double(layer) * 16000)

                    let glowCircle = HeatmapCircle(center: rr.center, radius: expandedRadius)
                    glowCircle.riskRegion = rr
                    glowCircle.glowLayer = layer
                    glowCircle.totalLayers = rr.severity.glowLayers
                    map.addOverlay(glowCircle, level: .aboveRoads)
                }

                let baseCircle = HeatmapCircle(center: rr.center, radius: rr.radiusMeters)
                baseCircle.riskRegion = rr
                baseCircle.glowLayer = 0
                baseCircle.totalLayers = rr.severity.glowLayers
                map.addOverlay(baseCircle, level: .aboveRoads)
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circle = overlay as? HeatmapCircle,
                  let rr = circle.riskRegion else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKCircleRenderer(circle: circle)

            if circle.glowLayer == 0 {
                renderer.fillColor = rr.severity.primaryUIColor.withAlphaComponent(rr.severity.fillAlpha)
                renderer.strokeColor = rr.severity.secondaryUIColor.withAlphaComponent(rr.severity.strokeAlpha)
                renderer.lineWidth = rr.severity.lineWidth
            } else {
                let total = Double(circle.totalLayers)
                let current = Double(circle.glowLayer)
                let alphaFraction = 1.0 - (current / total)
                let glowAlpha = rr.severity.fillAlpha * alphaFraction * 0.65

                let blendedColor = interpolatedColor(
                    from: rr.severity.primaryUIColor,
                    to: rr.severity.secondaryUIColor,
                    t: current / total
                )

                renderer.fillColor = blendedColor.withAlphaComponent(glowAlpha)
                renderer.strokeColor = .clear
                renderer.lineWidth = 0
            }

            return renderer
        }

        private func interpolatedColor(from c1: UIColor, to c2: UIColor, t: Double) -> UIColor {
            var r1: CGFloat = 0
            var g1: CGFloat = 0
            var b1: CGFloat = 0
            var a1: CGFloat = 0

            var r2: CGFloat = 0
            var g2: CGFloat = 0
            var b2: CGFloat = 0
            var a2: CGFloat = 0

            c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

            return UIColor(
                red: r1 + (r2 - r1) * t,
                green: g1 + (g2 - g1) * t,
                blue: b1 + (b2 - b1) * t,
                alpha: 1
            )
        }

        @objc func handleMapTap(_ recognizer: UITapGestureRecognizer) {
            guard let mapView = recognizer.view as? MKMapView else { return }
            let tapPoint = recognizer.location(in: mapView)

            for overlay in mapView.overlays {
                guard
                    let circle = overlay as? HeatmapCircle,
                    circle.glowLayer == 0,
                    let rr = circle.riskRegion,
                    let renderer = mapView.renderer(for: circle) as? MKCircleRenderer
                else { continue }

                let mapPoint = MKMapPoint(mapView.convert(tapPoint, toCoordinateFrom: mapView))
                let rendererPoint = renderer.point(for: mapPoint)
                let circleBounds = renderer.path.boundingBox

                if circleBounds.contains(rendererPoint) {
                    let center = CGPoint(x: circleBounds.midX, y: circleBounds.midY)
                    let dx = rendererPoint.x - center.x
                    let dy = rendererPoint.y - center.y
                    let distance = sqrt(dx * dx + dy * dy)

                    if distance <= circleBounds.width / 2 {
                        onSelect(rr)
                        return
                    }
                }
            }
        }
    }
}

final class HeatmapCircle: MKCircle {
    var riskRegion: RiskRegion?
    var glowLayer: Int = 0
    var totalLayers: Int = 1
}

#Preview {
    OntarioMapView()
}
