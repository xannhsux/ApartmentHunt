//
//  UserPreferences.swift - For ranking apartments
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class UserPreferences {
    // Ranking factors with weights (0-10)
    var priceImportance: Int = 8
    var locationImportance: Int = 7
    var safetyImportance: Int = 9
    var amenitiesImportance: Int = 5
    var noiseImportance: Int = 6
    var lightImportance: Int = 4
    
    // Relationship to user
    @Relationship var user: User?
    
    // Convert to dictionary for easier use in ranking algorithm
    func asDictionary() -> [String: Int] {
        return [
            "price": priceImportance,
            "location": locationImportance,
            "safety": safetyImportance,
            "amenities": amenitiesImportance,
            "noise": noiseImportance,
            "light": lightImportance
        ]
    }
    
    init() {}
}
