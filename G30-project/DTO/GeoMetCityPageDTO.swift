import Foundation

struct GeoMetCityPageDTO: Decodable {
    let id: String
    let properties: PropertiesDTO

    struct PropertiesDTO: Decodable {
        let identifier: String?
        let name: LocalizedText
        let currentConditions: CurrentConditionsDTO?
        let forecastGroup: ForecastGroupDTO?
        let warnings: [WarningDTO]?

        struct WarningDTO: Decodable {
            let description: LocalizedText?
            let alertColourLevel: LocalizedText?
        }
    }

    struct LocalizedText: Decodable {
        let en: String?
        let fr: String?
    }

    struct CurrentConditionsDTO: Decodable {
        let condition: LocalizedText?
        let temperature: MeasurementValueDTO?
    }

    struct MeasurementValueDTO: Decodable {
        let value: LocalizedDouble?
        let units: LocalizedText?
    }

    struct LocalizedDouble: Decodable {
        let en: Double?
        let fr: Double?
    }

    struct ForecastGroupDTO: Decodable {
        let textSummary: LocalizedText?
        let forecasts: [ForecastPeriodDTO]?
    }

    struct ForecastPeriodDTO: Decodable {
        let period: PeriodDTO?
        let temperatures: TemperaturesDTO?
        let cloudPrecip: LocalizedText?
        let textSummary: LocalizedText?
    }

    struct PeriodDTO: Decodable {
        let textForecastName: LocalizedText?
    }

    struct TemperaturesDTO: Decodable {
        let temperature: [TemperatureDetailDTO]?
        let textSummary: LocalizedText?
    }

    struct TemperatureDetailDTO: Decodable {
        let value: LocalizedDouble?
        let className: LocalizedText?

        enum CodingKeys: String, CodingKey {
            case value
            case className = "class"
        }
    }
}
