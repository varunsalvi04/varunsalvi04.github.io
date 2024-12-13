import UIKit
import GooglePlaces
import SwiftUI

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var placesClient: GMSPlacesClient!
    private var tableView: UITableView!
    private var predictions: [GMSAutocompletePrediction] = []
    var onCitySelected: ((GMSPlace) -> Void)?
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust size as needed
        button.addTarget(self, action: #selector(clearSearchField), for: .touchUpInside)
        return button
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter City Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false

        
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        paddingView.addSubview(imageView)
        imageView.center = paddingView.center

        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        

        return textField
    }()
    
   

    @objc private func clearSearchField() {
        searchTextField.text = ""
        predictions = []
        tableView.isHidden = true
        tableView.reloadData()
        searchTextField.rightView = nil // Hide the cancel button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        // Add a target to monitor changes in the text field
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupSearchTextField(in: contentView)
        setupTableView(in: contentView)
    }
    
    private func setupSearchTextField(in contentView: UIView) {
        contentView.addSubview(searchTextField)
        searchTextField.delegate = self
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupTableView(in contentView: UIView) {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        tableView.isHidden = true
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text, !query.isEmpty else {
            predictions = []
            tableView.isHidden = true
            tableView.reloadData()
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        filter.country = "US"
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { (results, error) in
            if let error = error {
                print("Error fetching autocomplete predictions: \(error)")
                return
            }
            
            self.predictions = results ?? []
            self.tableView.isHidden = self.predictions.isEmpty
            self.tableView.reloadData()
        }
        if let text = textField.text, !text.isEmpty {
            searchTextField.rightView = cancelButton // Show the cancel button
            searchTextField.rightViewMode = .always
        } else {
            searchTextField.rightView = nil // Hide the cancel button
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = predictions[indexPath.row].attributedPrimaryText.string
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPrediction = predictions[indexPath.row]
        let placeID = selectedPrediction.placeID // Get the Place ID
        
        // Fetch place details
        let fields: GMSPlaceField = [.name, .coordinate, .placeID]
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { (place, error) in
            if let error = error {
                print("Error fetching place details: \(error)")
                return
            }
            
            if let place = place {
                // Print the city name and coordinates
                print("Selected City: \(place.name ?? "Unknown City")")
                print("Coordinates: \(place.coordinate.latitude), \(place.coordinate.longitude)")
                self.onCitySelected?(place)
                // Update the search field
                self.searchTextField.text = place.name
            }
        }
        
        predictions = []
        tableView.isHidden = true
        tableView.reloadData()
    }
    
    
    

}
