//
//  Apartment.swift - Core data model for listings
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Apartment {
    @Attribute(.unique) var id: String
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var latitude: Double
    var longitude: Double
    
    // Basic details
    var price: Double
    var bedrooms: Int
    var bathrooms: Double
    var squareFeet: Int
    
    // Additional details
    var floorNumber: Int?
    var unitNumber: String?
    var totalFloors: Int?
    var yearBuilt: Int?
    var orientation: String? // N, S, E, W, etc.
    var petPolicy: String?
    var parkingAvailable: Bool
    var parkingFee: Double?
    
    // Amenities
    var amenities: [String]
    
    // Media
    var imageURLs: [String]
    var floorPlanURL: String?
    var virtualTourURL: String?
    
    // Contact information
    var contactName: String?
    var contactPhone: String?
    var contactEmail: String?
    
    // Availability
    var availableFrom: Date
    
    // Review data (aggregated)
    var averageRating: Double?
    var reviewCount: Int = 0
    var noiseLevel: Double? // 1-10 scale
    var managementRating: Double? // 1-10 scale
    var valueRating: Double? // 1-10 scale
    
    // Relationships
    @Relationship(deleteRule: .cascade) var reviews: [Review]? = []
    @Relationship(deleteRule: .cascade) var tours: [TouredApartment]? = []
    
    // Match score (calculated during search)
    @Transient var matchScore: Double?
    
    init(
        id: String, name: String, address: String, city: String, state: String, zipCode: String,
        latitude: Double, longitude: Double, price: Double, bedrooms: Int, bathrooms: Double,
        squareFeet: Int, amenities: [String], imageURLs: [String], availableFrom: Date,
        parkingAvailable: Bool = false
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.price = price
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.squareFeet = squareFeet
        self.amenities = amenities
        self.imageURLs = imageURLs
        self.availableFrom = availableFrom
        self.parkingAvailable = parkingAvailable
    }
}
