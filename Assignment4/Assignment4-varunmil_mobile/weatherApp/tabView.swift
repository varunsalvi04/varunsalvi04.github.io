import SwiftUI
import GooglePlaces
import SwiftSpinner

struct tabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var selectedCity: GMSPlace?
    var body: some View {
        
        VStack {
            buttonView(selectedCity: $selectedCity, currentView: "tabView")
                .environmentObject(locationManager)
            TabBar()
        }
    }
}

struct today: View{
    @EnvironmentObject var weatherService: WeatherService
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View{
        
        
        ZStack {
            GeometryReader { geometry in
                Image("App_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 35) {
                HStack(spacing: 15) { 
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        VStack{
                            // Temperature
                            Image("WindSpeed")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.black)
                            
                            if(!weatherService.weatherRecords.isEmpty){
                                Text("\(Int(weatherService.weatherRecords[0].values.windSpeed)) mph")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                            
                            // City name
                            Text("Wind Speed")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        VStack{
                            // Temperature
                            Image("Pressure")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.black)
                            
                            if(!weatherService.weatherRecords.isEmpty){
                                Text("\(Int(weatherService.weatherRecords[0].values.pressureSeaLevel)) inHg")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                            
                            // City name
                            Text("Pressure")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        VStack{
                            Image("Precipitation")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.black)
                            
                            // Weather description
                            if(!weatherService.weatherRecords.isEmpty){
                                Text("\(Int(weatherService.weatherRecords[0].values.precipitationProbability)) %")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                            
                            // City name
                            Text("Precipitation")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                HStack(spacing: 15) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        VStack{
                            // Temperature
                            Image("Temperature")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.black)
                            
                            // Weather description
                            if(!weatherService.weatherRecords.isEmpty){
                                Text("\(Int(weatherService.weatherRecords[0].values.temperature.rounded())) °F")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                            
                            
                            // City name
                            Text("Temperature")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        if(!weatherService.weatherRecords.isEmpty){
                            VStack{
                                Image("\(Int(weatherService.weatherRecords[0].values.weatherCode))")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black)
                                
                                let weatherCode = WeatherCodes(rawValue: weatherService.weatherRecords[0].values.weatherCode)
                                
                                // City name
                                Text(weatherCode!.description)
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        if(!weatherService.weatherRecords.isEmpty){
                            VStack{
                                Image("Humidity")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black)
                                
                                // Weather description
                                Text("\(Int(weatherService.weatherRecords[0].values.humidity.rounded())) %")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                
                                // City name
                                Text("Humidity")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                }
                
                HStack(spacing: 15) {
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        if(!weatherService.weatherRecords.isEmpty){
                            VStack{
                                Image("Visibility")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black)
                                
                                // Weather description
                                Text("\(Int(weatherService.weatherRecords[0].values.visibility)) mi")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                
                                // City name
                                Text("Visibility")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        if(!weatherService.weatherRecords.isEmpty){
                            VStack{
                                Image("CloudCover")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black)
                                
                                // Weather description
                                Text("\(Int(weatherService.weatherRecords[0].values.cloudCover)) %")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                
                                // City name
                                Text("Cloud Cover")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.5))
                            .frame(width: 120, height: 180)
                        if(!weatherService.weatherRecords.isEmpty){
                            VStack{
                                Image("UVIndex")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.black)
                                
                                // Safely unwrap the optional uvIndex
                                if let uvIndex = weatherService.weatherRecords[0].values.uvIndex {
                                    Text("\(uvIndex)") // uvIndex is now safely unwrapped
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                } else {
                                    Text("N/A") // Display a fallback if uvIndex is nil
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                }
                                
                                // City name
                                Text("UVIndex")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                }
            }
            .padding(20) // Adds padding around the VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        
        
        
    }
    
}

struct weekly: View{
    @EnvironmentObject var weatherService: WeatherService
    @State private var isLoading = true
    
    var body: some View{
        
        //        buttonView()
        ZStack {
            GeometryReader { geometry in
                Image("App_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            }
            
            ZStack {
                
                // RoundedRectangle as the background
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2) // Adds the white outline with slight opacity
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.5)) // Fills the inner rectangle with white opacity
                    )
                    .frame(width: 400, height: 200)
                    .padding(.top, 5)
                
                HStack(spacing: 20) {
                                    if(!weatherService.weatherRecords.isEmpty) {
                                        Image("\(Int(weatherService.weatherRecords[0].values.weatherCode))")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding(.leading, 30)
                                        
                                        VStack(alignment: .leading, spacing: 15) {
                                            let weatherCode = WeatherCodes(rawValue: weatherService.weatherRecords[0].values.weatherCode)
                                            Text(weatherCode!.description)
                                                .font(.system(size: 30))
                                                .foregroundColor(.black)
                                            
                                            Text("\(Int(weatherService.weatherRecords[0].values.temperature.rounded())) °F")
                                                .font(.system(size: 30, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            
                                        }
                                        .padding(.leading, 20)
                                    }
                                }
                            }
                            .padding(.top, -350)
//            print(weatherService.dailyRecords)
            //            if let intervals = weatherService.dailyRecords {
            let temperatureDataArray: [[Any]] = weatherService.weatherRecords.compactMap { interval in
                guard let startTime = interval.startTime as? String,
                      let values = interval.values as? WeatherData,
                      let highTemp = values.temperatureMax.rounded() as? Double,
                      let lowTemp = values.temperatureMin.rounded() as? Double,
                      let date = ISO8601DateFormatter().date(from: startTime) else {
                    return nil
                }
                let timestamp = Int(date.timeIntervalSince1970 * 1000)
                return [timestamp,  highTemp,  lowTemp]
            }
            
            HighchartViewRepresentable(data: temperatureDataArray)
                .frame(height: 300)
                .padding(.top, 120)
            //                        }
            
            Spacer()
            
        }.onAppear {
            
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
}


struct weatherData: View{
    @EnvironmentObject var weatherService: WeatherService
    @State private var isLoading = true
    
    var body: some View{
        
        //        buttonView()
        ZStack {
            GeometryReader { geometry in
                Image("App_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
            }
            
            ZStack {
                
                // RoundedRectangle as the background
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2) // Adds the white outline with slight opacity
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.5)) // Fills the inner rectangle with white opacity
                    )
                    .frame(width: 380, height: 170)
                    .padding(.top, 50)
                
                    VStack(spacing: 3){
                        // Image placed on top
                        Image("Precipitation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50) // Adjust size as needed
                        // Optional adjustment for image position
                        
                        // Image placed on top
                        Image("Humidity")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50) // Adjust size as needed
                        // Optional adjustment for image position
                        
                        // Image placed on top
                        Image("CloudCover")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50) // Adjust size as needed
                        // Optional adjustment for image position
                    }.padding(.leading, -150)
                        .padding(.top, 50)
                    
                if(!weatherService.weatherRecords.isEmpty){
                    VStack(alignment: .leading, spacing: 25) {
                        // Temperature
                        Text("Precipitation: \(Int(weatherService.weatherRecords[0].values.precipitationProbability)) %")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        // Weather description
                        Text("Humidity: \(Int(weatherService.weatherRecords[0].values.humidity.rounded())) %")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                        
                        // City name
                        Text("Cloud Cover: \(Int(weatherService.weatherRecords[0].values.cloudCover)) %")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 30)
                    .padding(.top, 50)
                }
                    
                
                
            }
            .padding(.top, -350)
            
            let weatherData: (precipitation: Double, humidity: Double, cloudCover: Double)? = weatherService.weatherRecords.compactMap { interval in
                guard let values = interval.values as? WeatherData,
                      let precipitation = values.precipitationProbability as? Double,
                      let humidity = values.humidity.rounded() as? Double,
                      let cloudCover = values.cloudCover.rounded() as? Double else {
                    return nil
                }
                return (precipitation: precipitation, humidity: humidity, cloudCover: cloudCover)
            }.first
            
            if let weatherData = weatherData {
                GaugeView(weatherData: weatherData)
                    .frame(height: 150)
                    .padding(.top, -80)
            }

            // Adjust the frame as needed
            
            
        }
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
}

struct TabBar: View{
    @EnvironmentObject var weatherService: WeatherService
    
    var body: some View{
        
        TabView{
            NavigationStack() {
                today()
            }
            .tabItem {
                Text("TODAY")
                Image("Today_Tab")
                    .renderingMode(.template)
            }
            
            NavigationStack() {
                weekly().environmentObject(weatherService)
            }
            .tabItem {
                Text("WEEKLY")
                Image("Weekly_Tab")
                    .renderingMode(.template)
            }
            
            NavigationStack() {
                weatherData().environmentObject(weatherService)
                
            }
            .tabItem {
                Text("WEATHER DATA")
                Image("Weather_Data_Tab")
                    .renderingMode(.template)
                
            }
            
        }
        .background(Color.clear.edgesIgnoringSafeArea(.all))
        
        
        
    }
    
}

