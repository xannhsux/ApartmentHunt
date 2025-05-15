//
//  APTApp.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import SwiftUI
import SwiftData

@main
struct APTApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Apartment.self,
            User.self,
            UserPreferences.self,
            Review.self,
            SavedSearch.self,
            TouredApartment.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Configuration for Llama 3 API
    private let llamaConfig = LlamaConfig()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.llamaConfig, llamaConfig)
        }
        .modelContainer(sharedModelContainer)
    }
}

// Llama 3 API configuration
struct LlamaConfig {
    let apiEndpoint: String
    let apiKey: String
    
    init() {
        // Read from environment or configuration
        self.apiEndpoint = ProcessInfo.processInfo.environment["LLAMA_API_ENDPOINT"] ?? "https://api.llama.your-provider.com/v1/completions"
        self.apiKey = ProcessInfo.processInfo.environment["LLAMA_API_KEY"] ?? ""
    }
}

// Environment key for Llama 3 configuration
private struct LlamaConfigKey: EnvironmentKey {
    static let defaultValue = LlamaConfig()
}

extension EnvironmentValues {
    var llamaConfig: LlamaConfig {
        get { self[LlamaConfigKey.self] }
        set { self[LlamaConfigKey.self] = newValue }
    }
}
