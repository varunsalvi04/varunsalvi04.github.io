import SwiftUI
import UIKit
import GooglePlaces

struct PlacesSearchView: UIViewControllerRepresentable {
    var onCitySelected: (GMSPlace) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ViewController()
        viewController.onCitySelected = onCitySelected // Pass callback
        // Pass the callback closure
        return viewController// Your UIKit ViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}



