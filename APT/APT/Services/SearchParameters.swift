//
//  SearchParameters.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation

/// Model that represents the parsed search parameters from a natural language query
struct SearchParameters: Codable {
    var location: Location
    var priceRange: PriceRange
    var bedrooms: Int
    var bathrooms: Double
    var sizeRange: SizeRange
    var apartmentType: String
    var orientation: String
    var floorPreference: String
    var petPolicy: String
    var noisePreference: String
    var amenities: [String]
    var otherRequirements: [String]
    
    // Review-related parameters (added during enhancement)
    var reviewKeywords: [String] = []
    
    var description: String {
        """
        Location: \(location.city), \(location.neighborhood ?? "")
        Price: $\(priceRange.min) - $\(priceRange.max)
        Size: \(bedrooms) bed, \(bathrooms) bath
        Type: \(apartmentType)
        Orientation: \(orientation)
        Floor: \(floorPreference)
        Pets: \(petPolicy)
        Noise: \(noisePreference)
        Amenities: \(amenities.joined(separator: ", "))
        Other Requirements: \(otherRequirements.joined(separator: ", "))
        """
    }
    
    /// Location parameters with city and optional neighborhood
    struct Location: Codable {
        var city: String
        var neighborhood: String?
    }
    
    /// Price range with minimum and maximum values
    struct PriceRange: Codable {
        var min: Int
        var max: Int
    }
    
    /// Size range with minimum and maximum square footage
    struct SizeRange: Codable {
        var min: Int
        var max: Int
    }
    
    /// Default initializer with empty/default values
    init() {
        self.location = Location(city: "", neighborhood: nil)
        self.priceRange = PriceRange(min: 0, max: 10000)
        self.bedrooms = 1
        self.bathrooms = 1.0
        self.sizeRange = SizeRange(min: 0, max: 5000)
        self.apartmentType = ""
        self.orientation = ""
        self.floorPreference = ""
        self.petPolicy = ""
        self.noisePreference = ""
        self.amenities = []
        self.otherRequirements = []
    }
    
    /// Custom initializer with all parameters
    init(location: Location, priceRange: PriceRange, bedrooms: Int, bathrooms: Double,
         sizeRange: SizeRange, apartmentType: String, orientation: String,
         floorPreference: String, petPolicy: String, noisePreference: String,
         amenities: [String], otherRequirements: [String]) {
        self.location = location
        self.priceRange = priceRange
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.sizeRange = sizeRange
        self.apartmentType = apartmentType
        self.orientation = orientation
        self.floorPreference = floorPreference
        self.petPolicy = petPolicy
        self.noisePreference = noisePreference
        self.amenities = amenities
        self.otherRequirements = otherRequirements
    }
}

// Coding key extensions for flexible JSON parsing
extension SearchParameters {
    private enum CodingKeys: String, CodingKey {
        case location
        case priceRange = "price_range"
        case bedrooms
        case bathrooms
        case sizeRange = "size_range"
        case apartmentType = "apartment_type"
        case orientation
        case floorPreference = "floor_preference"
        case petPolicy = "pet_policy"
        case noisePreference = "noise_preference"
        case amenities
        case otherRequirements = "other_requirements"
    }
    
    // Custom decoder to handle missing fields or unexpected JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with defaults
        location = try container.decodeIfPresent(Location.self, forKey: .location) ?? Location(city: "", neighborhood: nil)
        priceRange = try container.decodeIfPresent(PriceRange.self, forKey: .priceRange) ?? PriceRange(min: 0, max: 10000)
        bedrooms = try container.decodeIfPresent(Int.self, forKey: .bedrooms) ?? 1
        bathrooms = try container.decodeIfPresent(Double.self, forKey: .bathrooms) ?? 1.0
        sizeRange = try container.decodeIfPresent(SizeRange.self, forKey: .sizeRange) ?? SizeRange(min: 0, max: 5000)
        
        // Optional text fields
        apartmentType = try container.decodeIfPresent(String.self, forKey: .apartmentType) ?? ""
        orientation = try container.decodeIfPresent(String.self, forKey: .orientation) ?? ""
        floorPreference = try container.decodeIfPresent(String.self, forKey: .floorPreference) ?? ""
        petPolicy = try container.decodeIfPresent(String.self, forKey: .petPolicy) ?? ""
        noisePreference = try container.decodeIfPresent(String.self, forKey: .noisePreference) ?? ""
        
        // Array fields
        amenities = try container.decodeIfPresent([String].self, forKey: .amenities) ?? []
        otherRequirements = try container.decodeIfPresent([String].self, forKey: .otherRequirements) ?? []
    }
}
