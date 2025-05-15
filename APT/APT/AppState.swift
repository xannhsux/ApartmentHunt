//
//  AppState.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI

@Observable class AppState {
    var currentUser: User?
    var searchResults: [Apartment] = []
    var savedSearches: [SavedSearch] = []
    var touredApartments: [TouredApartment] = []
    
    // User preferences for apartment ranking
    var userPreferences: UserPreferences = UserPreferences()
    
    static let shared = AppState()
    
    private init() {
        // Load user data from persistent storage
    }
}
