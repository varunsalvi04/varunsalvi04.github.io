import SwiftUI
import GooglePlaces
import Foundation
import SwiftSpinner
import SimpleToast

struct ContentView: View {
    @StateObject var weatherService = WeatherService()
    @StateObject private var locationManager = LocationManager()
    @StateObject var favoriteCityService = FavoriteCityService()
    @State private var offset: CGFloat = 0 // Track the swipe offset
    @State private var showList: Bool = false
    @State private var selectedCity: GMSPlace?
    
    
    
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
                selectedCity = nil // Def	ault to nil if no favorite city
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                NavigationStack {
                    
                    if(!weatherService.weatherRecords.isEmpty){
                        VStack {
                            ImageOverlay(selectedCity: $selectedCity)
                                .environmentObject(weatherService)
                                .environmentObject(favoriteCityService)
                                .offset(x: offset) // Apply swipe offset
                                .offset(x: offset) // Apply swipe offset
                                .gesture(dragGesture())
                        }
                    }
                    
                }
                .onAppear {
                    if let location = locationManager.location {
                        weatherService.getWeatherRecords(lat: location.latitude, lon: location.longitude)
                    }
                }.onChange(of: locationManager.location) { newLocation in
                    if let location = newLocation {
                        weatherService.getWeatherRecords(lat: location.latitude, lon: location.longitude)
                    }
                }
                
                
                
            }
        }
        
        
        
    }
}

struct ImageOverlay: View{
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoriteCityService: FavoriteCityService
    @State private var searchText = ""
    @State private var searchIsActive = false
    @State private var selectedTab = "One"
    @State var isPlus = true
    @State private var showTabView = false
    @State private var isSearchActive = false
    @Binding  var selectedCity: GMSPlace?
    @State private var isLoading = true
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    
    private let toastOptions = SimpleToastOptions(
        alignment: .bottom,
        hideAfter: 2
    )
    
    var body: some View{
        
        
        ZStack{
            
            if selectedCity?.name == nil {
                // Simulate loading
                
                PlacesSearchView { city in
                    selectedCity = city
                    weatherService.getWeatherRecords(lat: city.coordinate.latitude, lon: city.coordinate.longitude)
                }
                .frame(maxHeight: 200) // Height of the search bar
                .zIndex(1)
                .offset(y: -410)
            } else {
                // Show the buttonView
                buttonView(selectedCity: $selectedCity,
                           currentView: "searchedView")
                .environmentObject(locationManager)
                .environmentObject(favoriteCityService)
                .zIndex(1)
                .offset(y: -410)
            }
            
            ZStack {
                
                GeometryReader { geometry in
                    Image("App_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)
                    //                        .resizable()
                    //                        .aspectRatio(contentMode: .fill)
                }
                
                VStack(spacing: 20) {
                    HStack {
                        Spacer() // Pushes the button to the right
                        
                
                        
                        if let city = selectedCity {
                            Spacer()
                            Button(action: {
                                print("click")
                                toggleFavorite(for: city)
                            }) {
                                Image(isPlus ? "plus-circle" : "close-circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                            .padding()
                            
                            .onAppear {
                                updateIsPlus(for: city)
                            }
                            .onChange(of: selectedCity) { newCity in
                                if let city = newCity {
                                    updateIsPlus(for: city)
                                }
                            }
                            
                        }
                    }
                    .padding(.leading, 250)
                    .frame(width: 390)
                    
                    ZStack {
                        GeometryReader { gp in     // << consumes all safe // RoundedRectangle as the background
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2) // Adds the white outline with slight opacity
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.5)) // Fills the inner rectangle with white opacity
                                )
                                .frame(width: 400, height: 170)
                                .padding(.top, 80)
                                .padding(.leading, 21)
                            
                            // Image placed on top
                            Image("\(Int(weatherService.weatherRecords[0].values.weatherCode))")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150) // Adjust size as needed
                                .padding(.top, 80)
                                .padding(.leading, 30)// Optional adjustment for image position
                            
                            
                            if(!weatherService.weatherRecords.isEmpty){
                                VStack(alignment: .leading, spacing: 15) {
                                    // Temperature
                                    Text("\(Int(weatherService.weatherRecords[0].values.temperature.rounded())) °F")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    let weatherCode = WeatherCodes(rawValue: weatherService.weatherRecords[0].values.weatherCode)
                                    
                                    // Weather description
                                    Text(weatherCode!.description)
                                        .font(.system(size: 30))
                                        .foregroundColor(.black)
                                    
                                    // City name
                                    Text(selectedCity?.name ?? locationManager.city ?? "")
                                        .font(.system(size: 30, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                .padding(.leading, 200)
                                .padding(.top, 100)
                            }
                        }
                        .onTapGesture {
                            showTabView = true
                        }
                        
                    }
                    .padding(.top, -85)
                    .fullScreenCover(isPresented: $showTabView) {
                        tabView(selectedCity: $selectedCity)
                            .environmentObject(locationManager) // Present TabView when tapped
                    }
                    // Ensure ZStack is properly aligned at the top
                    .onAppear {
                        
                        // Simulate loading
                        SwiftSpinner.show("Loading weather data...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            SwiftSpinner.hide()
                            isLoading = false // Stop showing spinner
                        }
                    }
                    if isLoading {
                        Color.black.opacity(0.5) // Background overlay
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                    }
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                WeatherInfoView()
                    .padding(.top, -160)
                //                .searchable(text: $searchText, isPresented: $searchIsActive)
                //                .searchable(text: $searchText, isPresented: $searchIsActive)
                Spacer()
                ForecastListView()
                    .padding(.top, 450)
                Spacer()
            }.zIndex(0)
                .offset(y:40)
        }.onChange(of: selectedCity) { newCity in
            if let city = newCity {
                weatherService.getWeatherRecords(lat: city.coordinate.latitude, lon: city.coordinate.longitude)
                
            }
        }
        .simpleToast(isPresented: $showToast, options: toastOptions) {
            Label(toastMessage, systemImage: "info.circle")
                .padding()
                .background(Color.black.opacity(0.8))
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.top)
        }
        
    }
    
    private func toggleFavorite(for city: GMSPlace) {
        Task {
            if isPlus {
                await favoriteCityService.addCities(city)
                toastMessage = "\(city.name ?? "City") was added to favorite list"
                isPlus = false
            } else {
                await favoriteCityService.deleteCity(city)
                toastMessage = "\(city.name ?? "City") was removed from favorite list"
                isPlus = true
            }
            
            await favoriteCityService.fetchCities()
            showToast = true
            //            updateIsPlus(for: city) // Update the button state after toggling
        }
    }
    
    private func updateIsPlus(for city: GMSPlace) {
        isPlus = !favoriteCityService.favoriteCities.contains(where: { $0.placeID == city.placeID })
    }
}

struct WeatherInfoView: View {
    @EnvironmentObject var weatherService: WeatherService
    var body: some View {
        HStack(spacing: 9) { // Adjust spacing for alignment
            WeatherElementView(
                iconName: "Humidity", // Replace with your asset name
                title: "Humidity",
                value: "\(Int(weatherService.weatherRecords[0].values.humidity.rounded())) %"
            )
            WeatherElementView(
                iconName: "WindSpeed", // Replace with your asset name
                title: "Wind Speed",
                value: "\(weatherService.weatherRecords[0].values.windSpeed.rounded()) mph"
            )
            WeatherElementView(
                iconName: "Visibility", // Replace with your asset name
                title: "Visibility",
                value: "\(weatherService.weatherRecords[0].values.visibility.rounded()) mi"
            )
            WeatherElementView(
                iconName: "Pressure", // Replace with your asset name
                title: "Pressure",
                value: "\(weatherService.weatherRecords[0].values.pressureSeaLevel.rounded()) inHg"
            )
        }
        //        .cornerRadius(10)
        //        .shadow(radius: 5)
        .frame(width: 440, height: 130)
    }
}

struct WeatherElementView: View {
    var iconName: String
    var title: String
    var value: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 18, weight: .regular, design: .default))
                .foregroundColor(.primary)
                .lineLimit(1)
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(value)
                .font(.system(.body, design: .default))
                .foregroundColor(.primary)
        }
    }
}

func formatDate(from dateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime]
    
    // Parse the ISO 8601 string into a Date object
    guard let date = isoFormatter.date(from: dateString) else {
        return dateString // Return original string if parsing fails
    }
    
    // Create a formatter for the desired output format
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy" // Desired format: day-month-year
    return dateFormatter.string(from: date)
}

func formatTime(from isoDateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime]
    
    // Try to parse the ISO string
    guard let date = isoFormatter.date(from: isoDateString) else {
        print("Failed to parse ISO date string: \(isoDateString)")
        return isoDateString // Return original string if parsing fails
    }
    
    // Format the Date object into a 12-hour time format
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
    dateFormatter.timeZone = TimeZone.current // Optional: Adjust to the user's time zone
    let formattedTime = dateFormatter.string(from: date)
    
    return formattedTime
}

struct ForecastListView: View {
    @EnvironmentObject var weatherService: WeatherService
    
    
    var body: some View {
        //        let weeklyForecast = []
        ZStack{
            
            List(weatherService.weatherRecords, id: \.self) { interval in
                HStack(spacing: 5){
                    Text(formatDate(from: interval.startTime)) // Customize as needed
                        .font(.system(size: 12))
                    
                    Spacer()
                    
                    Image("\(interval.values.weatherCode)") // Replace with your custom image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    Text(formatTime(from: interval.values.sunriseTime!))
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Image("sun-rise") // Replace with your custom image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    Text(formatTime(from: interval.values.sunsetTime!))
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Image("sun-set") // Replace with your custom image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
            }.listStyle(.plain) // Plain style for a simple table look
                .padding(25) // Optional padding inside the RoundedRectangle
                .background(Color.clear.opacity(0.1))
            
        }
    }
}





