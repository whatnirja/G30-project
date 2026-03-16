import Foundation

struct CityStationMapper {

    static func stationID(for city: String) -> String? {

        switch city.lowercased() {

        case "toronto":
            return "on-143"

        case "ottawa":
            return "on-118"

        case "london":
            return "on-141"

        case "windsor":
            return "on-129"

        case "hamilton":
            return "on-144"

        case "kingston":
            return "on-70"
        case "mississauga": return "on-143"
        case "brampton": return "on-143"
        case "waterloo": return "on-138"
        case "kitchener": return "on-138"
        default:
            return nil
        }
    }
}
