import Foundation
import CoreLocation

struct WeatherStation {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
}

final class WeatherStationLocator {

    static let shared = WeatherStationLocator()

    private let stations: [WeatherStation] = [
        WeatherStation(id: "on-143", name: "Toronto", latitude: 43.6532, longitude: -79.3832),
        WeatherStation(id: "on-118", name: "Ottawa", latitude: 45.4215, longitude: -75.6972),
        WeatherStation(id: "on-144", name: "Hamilton", latitude: 43.2557, longitude: -79.8711),
        WeatherStation(id: "on-141", name: "London", latitude: 42.9849, longitude: -81.2453),
        WeatherStation(id: "on-138", name: "Kitchener", latitude: 43.4516, longitude: -80.4925)
    ]

    func nearestStation(lat: Double, lon: Double) -> String? {
        let userLocation = CLLocation(latitude: lat, longitude: lon)

        let nearest = stations.min {
            let loc1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let loc2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude)

            return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
        }

        return nearest?.id
    }
}
