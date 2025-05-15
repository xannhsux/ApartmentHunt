//
//  ApartmentSearchService.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation
import SwiftData

actor ApartmentSearchService {
    private let modelContext: ModelContext
    private let nlSearchService: NLSearchService
    
    init(modelContext: ModelContext, llamaEndpoint: String, apiKey: String) {
        self.modelContext = modelContext
        self.nlSearchService = NLSearchService(apiEndpoint: llamaEndpoint, apiKey: apiKey)
    }
    
    // Main search function that takes natural language input
    func search(naturalLanguageQuery: String) async throws -> [Apartment] {
        // For now, just return any apartments in the database as a demonstration
        // We'll improve this later to actually use the NLSearchService
        let fetchDescriptor = FetchDescriptor<Apartment>(sortBy: [SortDescriptor(\.price)])
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // Basic function to generate a search summary
    func generateSearchSummary(apartments: [Apartment], query: String) async throws -> String {
        return "Found \(apartments.count) apartments matching your search for \"\(query)\"."
    }
}
