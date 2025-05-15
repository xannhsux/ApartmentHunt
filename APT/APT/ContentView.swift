//
//  ContentView.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isOnboarding = true  // Controls whether to show onboarding
    
    // Check if user exists to determine if onboarding is needed
    @Query private var users: [User]
    
    var body: some View {
        if users.isEmpty || isOnboarding {
            OnboardingView(isOnboarding: $isOnboarding)
        } else {
            MainTabView()
        }
    }
}

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    @Environment(\.modelContext) private var modelContext
    
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            // Progress dots
            HStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(currentPage == i ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 40)
            
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                welcomeView
                    .tag(0)
                
                // Page 2: Features
                featuresView
                    .tag(1)
                
                // Page 3: Create profile
                createProfileView
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Skip button if not on last page
            if currentPage < 2 {
                Button("Skip") {
                    createDefaultUser()
                    isOnboarding = false
                }
                .padding()
                .foregroundColor(.gray)
            }
        }
    }
    
    var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "building.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Apartment Hunt")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Find your perfect apartment using natural language search")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Next") {
                withAnimation {
                    currentPage = 1
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 50)
        }
        .padding()
    }
    
    var featuresView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            FeatureRow(icon: "text.magnifyingglass", title: "Natural Language Search", description: "Describe your ideal apartment in your own words")
            
            FeatureRow(icon: "star.fill", title: "User Reviews", description: "Read and write detailed apartment reviews")
            
            FeatureRow(icon: "list.clipboard", title: "Tour Tracking", description: "Record notes and rank apartments you've visited")
            
            Spacer()
            
            Button("Next") {
                withAnimation {
                    currentPage = 2
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
                .frame(height: 50)
        }
        .padding()
    }
    
    var createProfileView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Create Your Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tell us a bit about yourself to get personalized apartment recommendations")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
                .frame(height: 30)
            
            TextField("Your Name", text: $userName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Email Address", text: $userEmail)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Spacer()
            
            Button("Get Started") {
                createUser()
                isOnboarding = false
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(userName.isEmpty || userEmail.isEmpty)
            .opacity(userName.isEmpty || userEmail.isEmpty ? 0.5 : 1)
            
            Spacer()
                .frame(height: 50)
        }
        .padding()
    }
    
    struct FeatureRow: View {
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private func createUser() {
        let user = User(
            id: UUID().uuidString,
            name: userName.isEmpty ? "App User" : userName,
            email: userEmail.isEmpty ? "user@example.com" : userEmail
        )
        
        // Create default user preferences
        let preferences = UserPreferences()
        preferences.user = user
        
        modelContext.insert(user)
        modelContext.insert(preferences)
        
        // Set as current user in AppState
        AppState.shared.currentUser = user
        AppState.shared.userPreferences = preferences
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    private func createDefaultUser() {
        createUser()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Apartment.self, User.self, Review.self, SavedSearch.self, TouredApartment.self, UserPreferences.self], inMemory: true)
}
