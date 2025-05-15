//
//  User.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.


import Foundation
import SwiftUI
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var profileImageURL: String?
    
    // User preferences for notifications, etc.
    var notificationsEnabled: Bool = true
    
    // Relationships
    @Relationship(deleteRule: .cascade) var savedSearches: [SavedSearch]? = []
    @Relationship(deleteRule: .cascade) var touredApartments: [TouredApartment]? = []
    
    init(id: String, name: String, email: String, profileImageURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
    }
}
