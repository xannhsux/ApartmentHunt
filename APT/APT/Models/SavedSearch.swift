//
//  SavedSearch.swift - Model for saved searches
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class SavedSearch {
    @Attribute(.unique) var id: String
    var name: String
    var naturalLanguageQuery: String
    var createdAt: Date
    var lastUpdated: Date
    var isNotificationsEnabled: Bool
    
    // Relationship
    @Relationship var user: User?
    
    // The parsed requirements (for display)
    var parsedRequirements: [String: String]
    
    init(
        id: String = UUID().uuidString,
        name: String,
        naturalLanguageQuery: String,
        createdAt: Date = Date(),
        isNotificationsEnabled: Bool = true,
        parsedRequirements: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.naturalLanguageQuery = naturalLanguageQuery
        self.createdAt = createdAt
        self.lastUpdated = createdAt
        self.isNotificationsEnabled = isNotificationsEnabled
        self.parsedRequirements = parsedRequirements
    }
}
