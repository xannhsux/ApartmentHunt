//
//  TouredApartment.swift - Model for toured apartments
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class TouredApartment {
    @Attribute(.unique) var id: String
    
    // Relationships
    @Relationship var apartment: Apartment?
    @Relationship var user: User?
    
    var tourDate: Date
    
    // Notes from the tour
    var notes: String
    var pros: [String]
    var cons: [String]
    
    // Photos taken during tour
    var photoURLs: [String]
    
    // User ratings during tour
    var userRatings: [String: Int] // e.g. ["noise": 7, "light": 9]
    
    // Calculated rank based on user preferences
    var calculatedScore: Double?
    var calculatedRank: Int?
    
    init(
        id: String = UUID().uuidString,
        tourDate: Date = Date(),
        notes: String = "",
        pros: [String] = [],
        cons: [String] = [],
        photoURLs: [String] = [],
        userRatings: [String: Int] = [:]
    ) {
        self.id = id
        self.tourDate = tourDate
        self.notes = notes
        self.pros = pros
        self.cons = cons
        self.photoURLs = photoURLs
        self.userRatings = userRatings
    }
}
