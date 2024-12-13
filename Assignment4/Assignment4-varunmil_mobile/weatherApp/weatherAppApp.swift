import SwiftUI
import GooglePlaces

@main
struct weatherAppApp: App {
    var weatherService = WeatherService()
    var locationManager = LocationManager()
    var favoriteCityService = FavoriteCityService()
    
    
    // Integrate AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(weatherService)
                .environmentObject(favoriteCityService)
            
        }
    }
}

	
