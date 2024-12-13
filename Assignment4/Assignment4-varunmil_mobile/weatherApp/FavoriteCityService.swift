import SwiftUI
import GooglePlaces

struct City: Identifiable, Codable {
    let id = UUID() // Add an ID for SwiftUI's List
    let placeID: String
    let city: String
    let state: String
    let stateFullName: String
}

class FavoriteCityService: ObservableObject {
    @Published var favoriteCities: [GMSPlace] = []
    @Published var currentCityIndex: Int? = nil // Tracks the current city index

    private let listUri = "https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/list-favorite-cities"
    private let addUri = "https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/add-favorite-city"
    
    init() {
            Task {
                await fetchCities()
            }
        }

    func fetchCities() async {
        guard let url = URL(string: listUri) else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let cities = try JSONDecoder().decode([City].self, from: data)

            // Use placeID to reconstruct GMSPlace objects
            var places: [GMSPlace] = []
            for city in cities {
                if let place = await fetchGMSPlaceDetails(placeID: city.placeID) {
                    places.append(place)
                }
            }

            DispatchQueue.main.async {
                self.favoriteCities = places
            }
        } catch {
            print("Error fetching or decoding data: \(error.localizedDescription)")
        }
    }

    func addCities(_ place: GMSPlace) async {
        guard let url = URL(string: addUri) else {
            print("Invalid URL")
            return
        }

        let city = City(
            placeID: place.placeID ?? "",
            city: place.name ?? "",
            state: "", // Populate with actual state if available
            stateFullName: "" // Populate with actual state full name if available
        )

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Encode City object to JSON
            let jsonData = try JSONEncoder().encode(city)
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("City added successfully")
                
                await fetchCities()
            } else {
                print("Failed to add city")
            }
        } catch {
            print("Error adding city: \(error.localizedDescription)")
        }
    }

    private func fetchGMSPlaceDetails(placeID: String) async -> GMSPlace? {
        let fields: GMSPlaceField = [.name, .coordinate, .placeID, .formattedAddress]

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
                    if let error = error {
                        print("Error fetching place details: \(error.localizedDescription)")
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(returning: place)
                    }
                }
            }
        }
    }

    func deleteCity(_ city: GMSPlace) async {
        let uri = "https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/delete-favorite-city/\(city.name ?? "")"

        guard let url = URL(string: uri) else {
            print("Invalid URL")
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("City \(city.name ?? "") deleted successfully")
                // Optionally, decode updated list of cities
                let updatedCities = try JSONDecoder().decode([City].self, from: data)

                // Reconstruct GMSPlace objects
                var places: [GMSPlace] = []
                for city in updatedCities {
                    if let place = await fetchGMSPlaceDetails(placeID: city.placeID) {
                        places.append(place)
                    }
                }

                DispatchQueue.main.async {
                    self.favoriteCities = places
                }
            } else {
                print("Failed to delete city \(city.name ?? "")")
            }
        } catch {
            print("Error deleting city: \(error.localizedDescription)")
        }
    }
    
    func swipeLeft() {
        if currentCityIndex == nil {
            // If on the default first view, move to the first city
            currentCityIndex = favoriteCities.isEmpty ? nil : 0
        } else if let currentIndex = currentCityIndex {
            if currentIndex < favoriteCities.count - 1 {
                currentCityIndex = currentIndex + 1
            } else {
                currentCityIndex = nil // Loop back to the default first view
            }
        }
    }

    func swipeRight() {
        if currentCityIndex == nil {
            // If on the default first view, move to the last city
            currentCityIndex = favoriteCities.isEmpty ? nil : favoriteCities.count - 1
        } else if let currentIndex = currentCityIndex {
            if currentIndex > 0 {
                currentCityIndex = currentIndex - 1
            } else {
                currentCityIndex = nil // Navigate back to the default first view
            }
        }
    }
}
