import SwiftUI
import GooglePlaces
import Foundation

struct buttonView: View{
    
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var locationManager: LocationManager
    
    @EnvironmentObject var favoriteCityService: FavoriteCityService
    @Binding var selectedCity: GMSPlace?
    @State private var showHomePage = false
    @State private var showSearchedCity = false
    var currentView: String?
    private func dragGesture() -> some Gesture {
        DragGesture().onEnded { value in
            if value.translation.width < -50 { // Swipe left
                favoriteCityService.swipeLeft()
            } else if value.translation.width > 50 { // Swipe right
                favoriteCityService.swipeRight()
            }
            
            // Reset `selectedCity` to the new favorite city
            if let currentIndex = favoriteCityService.currentCityIndex,
               currentIndex < favoriteCityService.favoriteCities.count {
                selectedCity = favoriteCityService.favoriteCities[currentIndex]
            } else {
                if let location = locationManager.location {
                    weatherService.getWeatherRecords(lat: location.latitude, lon: location.longitude)
                }
                selectedCity = nil // Def    ault to nil if no favorite city
            }
        }
    }
    var body: some View {
        let urlData: (temperatureApparent: Double, weatherCode: Int)? = weatherService.weatherRecords.compactMap { interval in
            guard let values = interval.values as? WeatherData,
                  let temperatureApparent = values.temperatureApparent as? Double, // Corrected name
                  let weatherCode = values.weatherCode as? Int else { // Assuming cloudCover exists
                return nil
            }
            return (temperatureApparent: temperatureApparent, weatherCode: weatherCode)
        }.first
        HStack(spacing: 100){
            Button("< weather"){
                if(currentView == "searchedView"){
                    if let location = locationManager.location {
                        weatherService.getWeatherRecords(lat: location.latitude, lon: location.longitude)
                    }
                    showHomePage = true
                    selectedCity = nil
                }else if(currentView == "tabView"){
                    showSearchedCity = true
                }
            }
            
            Text(selectedCity?.name ?? locationManager.city ?? "Unknown Location")
            
            Button(action: {
                // Action to perform
                if let data = urlData {
                    // Construct URL with extracted values
                    let weatherDescription = WeatherCodes(rawValue: data.weatherCode)?.description ?? "Unknown"
                    let tweetText = "The current temperature at \(selectedCity?.name ?? locationManager.city ?? "Unknown Location") is \(data.temperatureApparent) °F. The weather consditions are  \(weatherDescription) #CSCI571WeatherSearch"
                    let urlString = "https://twitter.com/intent/tweet?text=\(tweetText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    
                    // Open the constructed URL
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                }
                
            }) {
                // Image view for the button
                Image("twitter")
                    .foregroundColor(.blue) 
            }
        }
        
        
        Spacer()
            .fullScreenCover(isPresented: $showHomePage) {
                ImageOverlay(selectedCity: $selectedCity)
                    .environmentObject(locationManager)
                    .environmentObject(weatherService)
                    .onDisappear {
                        showHomePage = false // Reset state when dismissed
                    }.gesture(dragGesture())
            }
        
        
        
            .fullScreenCover(isPresented: $showSearchedCity) {
                ImageOverlay(selectedCity:  $selectedCity)
                    .environmentObject(locationManager)
                    .environmentObject(weatherService)
                    .onDisappear {
                        showSearchedCity = false // Reset state when dismissed
                    }.gesture(dragGesture())
            }
    }
    
    
    
    
}
