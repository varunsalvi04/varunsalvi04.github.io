import SwiftUI
import GooglePlaces
import Foundation

struct FavoriteView: View {
    @State private var showSearchedCity = false
    var currentView: String?
    var selectedCity: GMSPlace?
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject var favoriteCityService: FavoriteCityService // Assuming MongoDbService is renamed to FavoriteCityService
    
    var body: some View {
        VStack {
            Text("Favorite Cities")
                .font(.largeTitle)
                .padding()
            
            if favoriteCityService.favoriteCities.isEmpty {
                Text("No favorite cities yet!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(favoriteCityService.favoriteCities, id: \.placeID) { city in
                    VStack(alignment: .leading) {
                        Text(city.name ?? "Unknown City")
                            .font(.headline)
                        if let address = city.formattedAddress {
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            Task {
                await favoriteCityService.fetchCities() // Refresh the list when the view appears
            }
        }
    }
}


