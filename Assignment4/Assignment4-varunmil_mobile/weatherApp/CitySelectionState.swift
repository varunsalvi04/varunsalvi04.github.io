import SwiftUI
import GooglePlaces

class CitySelectionState: ObservableObject {
    @Published var selectedCity: GMSPlace?

    init(initialCity: GMSPlace? = nil) {
        self.selectedCity = initialCity
    }
}
		
