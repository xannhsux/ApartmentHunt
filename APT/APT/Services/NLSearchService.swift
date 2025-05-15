//
//  NLSearchService.swift
//  APT
//
//  Created by Ann Hsu on 5/14/25.
//

import Foundation

/// A service that uses Llama 3 to process natural language apartment search queries
actor NLSearchService {
    private let llama3APIEndpoint: URL
    private let apiKey: String
    
    init(apiEndpoint: String, apiKey: String) {
        self.llama3APIEndpoint = URL(string: apiEndpoint)!
        self.apiKey = apiKey
    }
    
    /// Process a natural language query to extract structured search parameters
    func processQuery(_ query: String) async throws -> SearchParameters {
        // Construct prompt for the LLM
        let prompt = """
        Extract apartment search parameters from the following request:
        "\(query)"
        
        Return a JSON object with the following fields (if mentioned):
        - location (city, neighborhood)
        - price_range (min, max)
        - bedrooms (number)
        - bathrooms (number)
        - size_range (min, max in sq ft)
        - apartment_type (high-rise, garden, etc.)
        - orientation (north, south, east, west)
        - floor_preference (low, middle, high, any)
        - pet_policy (allowed, not allowed, cat only, dog only)
        - noise_preference (quiet, any)
        - amenities (array of requested amenities)
        - other_requirements (array of other specific requirements)
        
        Format your response as valid JSON only, with no additional text.
        """
        
        // Send request to Llama 3 API
        let llamaResponse = try await sendRequestToLlama3(prompt: prompt)
        
        // Parse the JSON response
        guard let jsonData = llamaResponse.data(using: .utf8) else {
            throw NLSearchError.invalidResponse
        }
        
        // Convert to SearchParameters object
        do {
            // Sometimes LLMs might return text around the JSON, so try to extract just the JSON
            let jsonString = extractJSON(from: llamaResponse)
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw NLSearchError.invalidResponse
            }
            
            let searchParams = try JSONDecoder().decode(SearchParameters.self, from: jsonData)
            return searchParams
        } catch {
            print("Error parsing JSON: \(error)")
            print("Response was: \(llamaResponse)")
            throw NLSearchError.parsingError(error)
        }
    }
    
    /// Enhance search with review insights
    func enhanceSearchWithReviews(parameters: SearchParameters) async throws -> SearchParameters {
        var enhancedParams = parameters
        
        // If there are subjective requirements, search reviews for relevant insights
        if !parameters.noisePreference.isEmpty || !parameters.otherRequirements.isEmpty {
            // Create a prompt to search for relevant review keywords
            let reviewPrompt = """
            Based on these apartment requirements:
            \(parameters.description)
            
            What specific words or phrases should I look for in apartment reviews to find matches?
            Return as a JSON array of keywords or phrases with no additional text.
            """
            
            // Get review keywords from LLM
            let llamaResponse = try await sendRequestToLlama3(prompt: reviewPrompt)
            
            // Extract JSON array from response
            let jsonString = extractJSON(from: llamaResponse)
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    let keywords = try JSONDecoder().decode([String].self, from: jsonData)
                    enhancedParams.reviewKeywords = keywords
                } catch {
                    print("Error parsing review keywords: \(error)")
                    print("Response was: \(jsonString)")
                }
            }
        }
        
        return enhancedParams
    }
    
    /// Send a request to the Llama 3 API
    private func sendRequestToLlama3(prompt: String) async throws -> String {
        // Prepare request body
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "max_tokens": 1024,
            "temperature": 0.2, // Lower temperature for more deterministic responses
            "top_p": 0.95       // Nucleus sampling for better quality JSON
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Create URL request
        var request = URLRequest(url: llama3APIEndpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NLSearchError.apiError("API returned error: \(response)")
        }
        
        // Parse response
        guard let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let completion = responseDict["completion"] as? String else {
            throw NLSearchError.invalidResponse
        }
        
        return completion
    }
    
    /// Extract JSON from a text response (sometimes LLMs include extra text)
    private func extractJSON(from text: String) -> String {
        // Look for JSON structure starting with { and ending with }
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            let jsonSubstring = text[startIndex...endIndex]
            return String(jsonSubstring)
        }
        
        // Try to find a JSON array instead
        if let startIndex = text.firstIndex(of: "["),
           let endIndex = text.lastIndex(of: "]") {
            let jsonSubstring = text[startIndex...endIndex]
            return String(jsonSubstring)
        }
        
        // Return the original if no JSON-like structure found
        return text
    }
    
    enum NLSearchError: Error {
        case invalidResponse
        case parsingError(Error)
        case apiError(String)
    }
}

// Helper extensions for better error messages
// This should be directly inside the NLSearchService file
enum NLSearchError: Error {
    case invalidResponse
    case parsingError(Error)
    case apiError(String)
}

// Helper extensions for better error messages
extension NLSearchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from language model"
        case .parsingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

