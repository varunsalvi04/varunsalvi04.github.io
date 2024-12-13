import CoreLocation


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    
    @Published var city: String? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.location = location.coordinate
                self.fetchCity(for: location)
            }
        }
        
    }
    
    private func fetchCity(for location: CLLocation) {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print("Reverse geocoding failed: \(error.localizedDescription)")
                    }
                } else if let placemark = placemarks?.first {
                    DispatchQueue.main.async {
                        self.city = placemark.locality ?? "Unknown"
                    }
                }
            }
        }
}
