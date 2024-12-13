import SwiftUI
import SwiftSpinner



class WeatherService: ObservableObject {
    @Published var weatherRecords: [Interval] = []
    @StateObject private var locationManager = LocationManager()
    
    @State private var isLoading = true
    private let uri =  "https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/weather?coordinates=%.6f,%.6f&timesteps=%@&weatherDataFields=temperature&weatherDataFields=temperatureApparent&weatherDataFields=temperatureMin&weatherDataFields=temperatureMax&weatherDataFields=windSpeed&weatherDataFields=windDirection&weatherDataFields=humidity&weatherDataFields=pressureSeaLevel&weatherDataFields=uvIndex&weatherDataFields=weatherCode&weatherDataFields=precipitationProbability&weatherDataFields=precipitationType&weatherDataFields=visibility&weatherDataFields=cloudCover"
    
    
    func getWeatherRecords(lat: Double, lon: Double)  {
       
            
            // Simulate loading
            SwiftSpinner.show("Loading weather data...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                SwiftSpinner.hide()
                self.isLoading = false // Stop showing spinner
            }
        
        if self.isLoading {
            Color.black.opacity(0.5) // Background overlay
                .edgesIgnoringSafeArea(.all)
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .foregroundColor(.white)
        }
        print("latitude \(lat), \(lon)")
        guard let url = URL(string: String(format:  uri+"&weatherDataFields=sunriseTime&&weatherDataFields=sunsetTime", lat, lon,"1d")) else { fatalError("Missing URL") }
        print(url)
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    do {
                        //                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        //                        print(jsonObject)
                        let decodedRecords = try JSONDecoder().decode(WeatherResponse.self, from: data)
                        self.weatherRecords = decodedRecords.data.timelines[0].intervals
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    
}
