//
//  CitySelection.swift
//  weatherApp
//
//  Created by Varun Salvi on 12/9/24.
//

// CitySelection.swift
import SwiftUI
import Combine

class CityViewModel: ObservableObject {
    @Published var selectedCity: String = "Unknown City"
}

