import UIKit
import GooglePlaces


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey("AIzaSyCzxQQwEMY-kUDuQ_Cz8-7uoXhu8BlhnHA")
        return true
    }
}
