import Foundation


// Define the model for the inner `values` dictionary
struct WeatherData: Decodable, Hashable {
    let cloudCover: Double
    let humidity: Double
    let precipitationProbability: Double
    let precipitationType: Int
    let pressureSeaLevel: Double
    let temperature: Double
    let temperatureApparent: Double
    let temperatureMax: Double
    let temperatureMin: Double
    let uvIndex: Int?
    let visibility: Double
    let weatherCode: Int
    let windDirection: Double
    let windSpeed: Double
    let sunriseTime: String?
    let sunsetTime: String?
}

// Define the model for the `warnings` array
struct WarningMeta: Decodable {
    let field: String
    let from: String
    let to: String
}

struct Warning: Decodable {
    let code: Int
    let type: String
    let message: String
    let meta: WarningMeta
}

// Define the top-level `data` object
struct DataContainer: Decodable {
    let timelines: [Timeline]
    let warnings: [Warning]
}

// Define the model for the ⁠ intervals ⁠ array
struct Interval: Decodable, Hashable, Equatable {
    let startTime: String
    let values: WeatherData
    let id = UUID() // Unique identifier for each interval
    // Custom Equatable implementation
    static func == (lhs: Interval, rhs: Interval) -> Bool {
        return lhs.id == rhs.id
    }
}

// Define the model for the ⁠ timelines ⁠ array
struct Timeline: Decodable {
    let timestep: String
    let endTime: String
    let startTime: String
    let intervals: [Interval]
}



// Define the entire response model
struct WeatherResponse: Decodable {
    let data: DataContainer
}
