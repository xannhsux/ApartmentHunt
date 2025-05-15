//
//  MainTabView.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.llamaConfig) private var llamaConfig
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SearchView(searchService: ApartmentSearchService(
                    modelContext: modelContext,
                    llamaEndpoint: llamaConfig.apiEndpoint,
                    apiKey: llamaConfig.apiKey
                ))
                .navigationTitle("Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(0)
            
            NavigationStack {
                SavedSearchesView()
                    .navigationTitle("Saved")
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark")
            }
            .tag(1)
            
            NavigationStack {
                ToursView(tourService: TourTrackingService(modelContext: modelContext))
                    .navigationTitle("Tours")
            }
            .tabItem {
                Label("Tours", systemImage: "list.clipboard")
            }
            .tag(2)
            
            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(3)
        }
    }
}

// Basic placeholder views (implement these further)
struct SearchView: View {
    let searchService: ApartmentSearchService
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Apartment] = []
    @State private var searchSummary: String?
    
    var body: some View {
        VStack {
            // Search header
            VStack(alignment: .leading) {
                Text("Find your perfect apartment")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("Describe what you're looking for in detail")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // Natural language search field
                HStack {
                    TextField("e.g., 1 bedroom in Los Angeles under $3000, quiet...", text: $searchText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        performSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(searchText.isEmpty || isSearching)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Search progress or results
            if isSearching {
                ProgressView("Searching with Llama 3...")
                    .padding()
            } else if !searchResults.isEmpty {
                // Search summary
                if let summary = searchSummary {
                    Text(summary)
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Text("\(searchResults.count) apartments found")
                    .font(.headline)
                    .padding(.top)
                
                List {
                    ForEach(searchResults) { apartment in
                        NavigationLink(destination: ApartmentDetailView(apartment: apartment)) {
                            ApartmentRowView(apartment: apartment)
                        }
                    }
                }
            } else {
                // Placeholder content for empty state
                VStack {
                    Spacer()
                    
                    Image(systemName: "building.2")
                        .font(.system(size: 70))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Start your search")
                        .font(.title2)
                        .padding()
                    
                    Text("Try searching for 'one bedroom in Los Angeles with a balcony' or 'pet-friendly studio near downtown'")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        searchSummary = nil
        
        Task {
            do {
                let results = try await searchService.search(naturalLanguageQuery: searchText)
                
                // Generate a summary of the results if we found any
                if !results.isEmpty {
                    let summary = try await searchService.generateSearchSummary(
                        apartments: results,
                        query: searchText
                    )
                    
                    await MainActor.run {
                        searchSummary = summary
                    }
                }
                
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                print("Search error: \(error)")
                await MainActor.run {
                    isSearching = false
                }
            }
        }
    }
}

struct ApartmentRowView: View {
    let apartment: Apartment
    
    var body: some View {
        HStack {
            // Apartment image
            if let firstImageURL = apartment.imageURLs.first, let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "building.2")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(apartment.name)
                    .font(.headline)
                
                Text("\(apartment.bedrooms) bed · \(apartment.bathrooms, specifier: "%.1f") bath · \(apartment.squareFeet) sq ft")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("$\(Int(apartment.price))/month")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let matchScore = apartment.matchScore {
                    Text("Match: \(Int(matchScore))%")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(matchScoreColor(score: matchScore).opacity(0.2))
                        .foregroundColor(matchScoreColor(score: matchScore))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func matchScoreColor(score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }
}

// Placeholder for apartment detail view
struct ApartmentDetailView: View {
    let apartment: Apartment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Images carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(apartment.imageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 300, height: 200)
                                .cornerRadius(10)
                                .clipped()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
                
                // Basic info
                VStack(alignment: .leading, spacing: 8) {
                    Text(apartment.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(apartment.address)
                        .font(.subheadline)
                    
                    Text("\(apartment.city), \(apartment.state) \(apartment.zipCode)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("$\(Int(apartment.price))/month")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 2)
                    
                    HStack(spacing: 20) {
                        FeatureItem(icon: "bed.double", text: "\(apartment.bedrooms) Beds")
                        FeatureItem(icon: "shower", text: "\(apartment.bathrooms) Baths")
                        FeatureItem(icon: "square", text: "\(apartment.squareFeet) sq ft")
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Additional details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                    
                    DetailRow(title: "Available From", value: apartment.availableFrom.formatted(date: .abbreviated, time: .omitted))
                    
                    if let floorNumber = apartment.floorNumber {
                        DetailRow(title: "Floor", value: "\(floorNumber)")
                    }
                    
                    if let orientation = apartment.orientation {
                        DetailRow(title: "Orientation", value: orientation)
                    }
                    
                    if let petPolicy = apartment.petPolicy {
                        DetailRow(title: "Pet Policy", value: petPolicy)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Amenities
                VStack(alignment: .leading, spacing: 12) {
                    Text("Amenities")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(apartment.amenities, id: \.self) { amenity in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(amenity)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Reviews summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reviews")
                        .font(.headline)
                    
                    if let averageRating = apartment.averageRating, apartment.reviewCount > 0 {
                        HStack {
                            Text("\(averageRating, specifier: "%.1f")")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading) {
                                StarsView(rating: Int(averageRating.rounded()))
                                Text("\(apartment.reviewCount) reviews")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                    } else {
                        Text("No reviews yet")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Call to action
                Button(action: {
                    // Schedule tour action
                }) {
                    Text("Schedule a Tour")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Apartment Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct FeatureItem: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(text)
                    .font(.subheadline)
            }
        }
    }
    
    struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
            }
            .font(.subheadline)
        }
    }
    
    struct StarsView: View {
        let rating: Int
        
        var body: some View {
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
    }
}

struct SavedSearchesView: View {
    var body: some View {
        Text("Saved Searches Coming Soon")
            .font(.headline)
            .padding()
    }
}

struct ToursView: View {
    let tourService: TourTrackingService
    
    var body: some View {
        Text("Tours Coming Soon")
            .font(.headline)
            .padding()
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile Coming Soon")
            .font(.headline)
            .padding()
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Apartment.self, User.self, Review.self, SavedSearch.self, TouredApartment.self, UserPreferences.self], inMemory: true)
        .environment(\.llamaConfig, LlamaConfig())
}
