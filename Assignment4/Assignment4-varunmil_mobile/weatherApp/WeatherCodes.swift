enum WeatherCodes: Int, CustomStringConvertible {
    case unknown = 0
    case clearSunny = 1000
    case cloudy = 1001
    case mostlyClear = 1100
    case partlyCloudy = 1101
    case mostlyCloudy = 1102
    case fog = 2000
    case lightFog = 2100
    case drizzle = 4000
    case rain = 4001
    case lightRain = 4200
    case heavyRain = 4201
    case snow = 5000
    case flurries = 5001
    case lightSnow = 5100
    case heavySnow = 5101
    case freezingDrizzle = 6000
    case freezingRain = 6001
    case lightFreezingRain = 6200
    case heavyFreezingRain = 6201
    case icePellets = 7000
    case heavyIcePellets = 7101
    case lightIcePellets = 7102
    case thunderstorm = 8000
    
    // Computed property to get the description
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .clearSunny: return "Clear, Sunny"
        case .cloudy: return "Cloudy"
        case .mostlyClear: return "Mostly Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .mostlyCloudy: return "Mostly Cloudy"
        case .fog: return "Fog"
        case .lightFog: return "Light Fog"
        case .drizzle: return "Drizzle"
        case .rain: return "Rain"
        case .lightRain: return "Light Rain"
        case .heavyRain: return "Heavy Rain"
        case .snow: return "Snow"
        case .flurries: return "Flurries"
        case .lightSnow: return "Light Snow"
        case .heavySnow: return "Heavy Snow"
        case .freezingDrizzle: return "Freezing Drizzle"
        case .freezingRain: return "Freezing Rain"
        case .lightFreezingRain: return "Light Freezing Rain"
        case .heavyFreezingRain: return "Heavy Freezing Rain"
        case .icePellets: return "Ice Pellets"
        case .heavyIcePellets: return "Heavy Ice Pellets"
        case .lightIcePellets: return "Light Ice Pellets"
        case .thunderstorm: return "Thunderstorm"
        }
    }
}
