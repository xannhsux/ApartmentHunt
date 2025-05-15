//
//  TourTrackingService.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftData
import PhotosUI
import SwiftUI

actor TourTrackingService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Start a new tour for an apartment
    func startTour(apartment: Apartment, user: User) async throws -> TouredApartment {
        let newTour = TouredApartment(
            tourDate: Date(),
            notes: "",
            pros: [],
            cons: [],
            photoURLs: [],
            userRatings: [:]
        )
        
        // Set relationships
        newTour.apartment = apartment
        newTour.user = user
        
        // Save to SwiftData
        modelContext.insert(newTour)
        try modelContext.save()
        
        return newTour
    }
    
    // Update tour notes
    func updateNotes(tourId: String, notes: String) async throws {
        let fetchDescriptor = FetchDescriptor<TouredApartment>(
            predicate: #Predicate { $0.id == tourId }
        )
        
        guard let tour = try modelContext.fetch(fetchDescriptor).first else {
            throw TourError.tourNotFound
        }
        
        tour.notes = notes
        try modelContext.save()
    }
    
    // Additional methods would go here
    
    enum TourError: Error {
        case tourNotFound
        case imageConversionFailed
    }
}
