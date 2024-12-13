import UIKit
import SwiftSpinner

class SearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Show the spinner
        SwiftSpinner.show("Fetching weather details for Los Angeles...")

        // Simulate a delay to dismiss the spinner
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            SwiftSpinner.hide()
        }
    }
}


#Preview {
    SearchViewController()
}
