//
//  Review.swift - Model for user reviews
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Review {
    @Attribute(.unique) var id: String
    
    // Relationships
    @Relationship var apartment: Apartment?
    @Relationship var user: User?
    
    var userName: String
    var datePosted: Date
    var overallRating: Int // 1-5
    
    // Specific ratings
    var noiseRating: Int? // 1-10
    var managementRating: Int? // 1-10
    var valueRating: Int? // 1-10
    var maintenanceRating: Int? // 1-10
    var locationRating: Int? // 1-10
    
    // Review content
    var title: String
    var content: String
    
    // Pros and cons
    var pros: [String]
    var cons: [String]
    
    // Media attachments
    var imageURLs: [String]?
    
    // Verification status
    var isVerified: Bool
    
    init(
        id: String = UUID().uuidString,
        userName: String,
        datePosted: Date = Date(),
        overallRating: Int,
        title: String,
        content: String,
        pros: [String] = [],
        cons: [String] = [],
        isVerified: Bool = false
    ) {
        self.id = id
        self.userName = userName
        self.datePosted = datePosted
        self.overallRating = overallRating
        self.title = title
        self.content = content
        self.pros = pros
        self.cons = cons
        self.isVerified = isVerified
    }
}
