//
//  ContentView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
// AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns

//import SwiftUI
//
//struct ContentView: View {
//  @State private var inputText = ""
//  @State private var apiOutput = ""
//  @State private var isLoading = false
//  @State private var sourceInfoText = ""
//  @State private var showSourceInfo = false
//  @State private var showingSourceInfoPopup = false  // New state for the popup
//
//  // Model initialization with latest Gemini model
//  let model = GenerativeModel(
//    name: "gemini-1.5-pro",
//    apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
//  )
//
//  var body: some View {
//    ZStack {  // ZStack allows overlay to appear on top of everything
//      VStack {
//        // Input field with search icon and underline
//        HStack {
//          TextField("Enter Semantic Scholar ID or Topic", text: $inputText)
//            .padding(.vertical, 1)
//            .padding(.horizontal, 30)
//            .background(Color.clear)
//            .overlay(
//              HStack {
//                Image(systemName: "magnifyingglass")
//                  .foregroundColor(.purple)
//                Spacer()
//              }
//              .padding(.leading, 8)
//            )
//            .padding(.horizontal)
//        }
//
//        // Underline for the input field
//        Rectangle()
//          .frame(height: 2)
//          .foregroundColor(.purple)
//          .padding(.bottom, 15)
//
//        // Button to fetch data
//        Button(action: {
//          Task {
//            isLoading = true
//            await fetchDataFromAPI()
//            isLoading = false
//          }
//        }) {
//          if isLoading {
//            ProgressView()
//              .progressViewStyle(CircularProgressViewStyle(tint: .white))
//              .padding()
//              .background(Color.purple)
//              .cornerRadius(10)
//              .shadow(radius: 3)
//          } else {
//            Text("Fetch Data")
//              .font(.headline)
//              .foregroundColor(.white)
//              .padding()
//              .background(Color.purple)
//              .cornerRadius(10)
//              .shadow(radius: 3)
//          }
//        }
//        .padding(.horizontal, 16)
//        .disabled(isLoading)
//
//        // Scrollable output text with toggle for source info
//        ScrollView {
//          VStack(alignment: .leading, spacing: 16) {
//            // Summary text
//            if !apiOutput.isEmpty {
//              Text(apiOutput)
//                .padding(.bottom, 8)
//            }
//
//  // Source info button - only shown when data is available
//            if !sourceInfoText.isEmpty {
//              Button(action: {
//                showingSourceInfoPopup = true  // Show the popup instead
//              }) {
//                HStack {
//                  Image(systemName: "info.circle")
//                        .foregroundColor(.purple)
//                  Text("Info about the source")
//                        .foregroundColor(.purple)
//                    .underline()
//                }
//              }
//              .padding(.leading, 16)
//              .buttonStyle(PlainButtonStyle())
//            }
//          }
//          .padding()
//          .frame(maxWidth: .infinity)
//          .background(
//            RoundedRectangle(cornerRadius: 10)
//              .fill(Color.gray.opacity(0.1))
//          )
//          .overlay(
//            RoundedRectangle(cornerRadius: 10)
//              .stroke(Color.black, lineWidth: 2)
//          )
//          .padding()
//// we want ts
//          
//        }
//      }
//      .padding()
//      
//      // Overlay for the source info popup
//      if showingSourceInfoPopup {
//        Color.black.opacity(0.4)
//          .edgesIgnoringSafeArea(.all)
//          .onTapGesture {
//            showingSourceInfoPopup = false
//          }
//        
//        VStack(alignment: .leading, spacing: 12) {
//          HStack {
//            Text("Source Information")
//              .font(.headline)
//              .foregroundColor(.primary)
//            
//            Spacer()
//            
//            Button(action: {
//              showingSourceInfoPopup = false
//            }) {
//              Image(systemName: "xmark.circle.fill")
//                .foregroundColor(.gray)
//                .font(.title2)
//            }
//          }
//          
//          Divider()
//          
//          ScrollView {
//            Text(sourceInfoText)
//              .font(.body)
//              .foregroundColor(.primary)
//          }
//        }
//        .padding()
//        .background(
//          RoundedRectangle(cornerRadius: 12)
//            .fill(Color.white)
//            .shadow(radius: 8)
//        )
//        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.6)
//        .transition(.scale)
//        .animation(.easeInOut, value: showingSourceInfoPopup)
//      }
//    }
//  }
//
//  // Function to handle fetching data based on input
//  func fetchDataFromAPI() async {
//    if inputText.hasPrefix("ARXIV:") || inputText.count == 40 {
//      await fetchFromSemanticScholarByID()
//    } else {
//      await fetchFromSemanticScholarBySearch()
//    }
//  }
//
//  // Fetch data from Semantic Scholar by ID
//  func fetchFromSemanticScholarByID() async {
//    let urlString =
//      "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,abstract,authors,url,year,venue"
//    guard let url = URL(string: urlString) else {
//      apiOutput = "Invalid URL."
//      return
//    }
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    let body: [String: [String]] = ["ids": [inputText]]
//
//    do {
//      request.httpBody = try JSONSerialization.data(withJSONObject: body)
//      let (data, _) = try await URLSession.shared.data(for: request)
//      if let json = try JSONSerialization.jsonObject(with: data)
//        as? [[String: Any]],
//        let firstPaper = json.first
//      {
//        let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
//        sourceInfoText = formattedOutput
//        let geminiPrompt =
//          "Summarize the following paper information in 3 sentences: \(formattedOutput)"
//        await processWithGemini(prompt: geminiPrompt)
//      } else {
//        apiOutput = "Could not parse Semantic Scholar response."
//        sourceInfoText = ""
//      }
//    } catch {
//      apiOutput = "Error fetching data from Semantic Scholar: \(error)"
//      sourceInfoText = ""
//    }
//  }
//
//  // Fetch data from Semantic Scholar by search
//  func fetchFromSemanticScholarBySearch() async {
//    guard
//      let encodedQuery = inputText.addingPercentEncoding(
//        withAllowedCharacters: .urlQueryAllowed)
//    else {
//      apiOutput = "Invalid search query."
//      return
//    }
//
//    let urlString =
//      "https://api.semanticscholar.org/graph/v1/paper/search?query=\(encodedQuery)&fields=title,abstract,authors,url,year,venue"
//    guard let url = URL(string: urlString) else {
//      apiOutput = "Invalid URL."
//      return
//    }
//
//    do {
//      let (data, _) = try await URLSession.shared.data(from: url)
//      if let json = try JSONSerialization.jsonObject(with: data)
//        as? [String: Any],
//        let dataArray = json["data"] as? [[String: Any]],
//        let firstPaper = dataArray.first
//      {
//        let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
//        sourceInfoText = formattedOutput
//        let geminiPrompt =
//          "Summarize the following paper information in 3 sentences: \(formattedOutput)"
//        await processWithGemini(prompt: geminiPrompt)
//      } else {
//        apiOutput = "Could not parse Semantic Scholar search response."
//        sourceInfoText = ""
//      }
//    } catch {
//      apiOutput = "Error fetching data from Semantic Scholar search: \(error)"
//      sourceInfoText = ""
//    }
//  }
//
//  // Format the Semantic Scholar response
//  func formatSemanticScholarResponse(paper: [String: Any]) -> String {
//    let title = paper["title"] as? String ?? "No Title"
//    let abstract = paper["abstract"] as? String ?? "No Abstract"
//    let authors =
//      (paper["authors"] as? [[String: String]])?.compactMap { $0["name"] }
//      .joined(separator: ", ") ?? "No Authors"
//    let url = paper["url"] as? String ?? "No URL"
//    let year = paper["year"] as? Int ?? 0
//    let venue = paper["venue"] as? String ?? "No Venue"
//
//    return """
//      Title: \(title)
//
//      Abstract: \(abstract)
//
//      Authors: \(authors)
//
//      URL: \(url)
//
//      Year: \(year)
//
//      Venue: \(venue)
//      """
//  }
//
//  // Process the data using the Gemini API
//  func processWithGemini(prompt: String) async {
//    do {
//      let response = try await model.generateContent(prompt)
//      apiOutput = response
//    } catch {
//      apiOutput = "Gemini API error: \(error.localizedDescription)"
//    }
//  }
//}
//
//// Fully implemented GenerativeModel struct with Gemini API functionality
//struct GenerativeModel {
//  let name: String
//  let apiKey: String
//  let baseURL = "https://generativelanguage.googleapis.com"
//
//  // Generation configuration
//  var temperature: Double = 0.2
//  var maxOutputTokens: Int = 1024
//  var topK: Int = 40
//  var topP: Double = 0.95
//
//  func generateContent(_ prompt: String) async throws -> String {
//    let endpoint = "\(baseURL)/v1/models/\(name):generateContent?key=\(apiKey)"
//
//    guard let url = URL(string: endpoint) else {
//      throw URLError(.badURL)
//    }
//
//    // Create the request payload
//    let requestBody: [String: Any] = [
//      "contents": [
//        [
//          "role": "user",
//          "parts": [
//            ["text": prompt]
//          ],
//        ]
//      ],
//      "generationConfig": [
//        "temperature": temperature,
//        "maxOutputTokens": maxOutputTokens,
//        "topK": topK,
//        "topP": topP,
//      ],
//    ]
//
//    // Create and configure the request
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//
//    // Send the request
//    let (data, response) = try await URLSession.shared.data(for: request)
//
//    // Check the response status code
//    guard let httpResponse = response as? HTTPURLResponse,
//      (200...299).contains(httpResponse.statusCode)
//    else {
//      // Try to extract error message if available
//      if let errorJson = try? JSONSerialization.jsonObject(with: data)
//        as? [String: Any],
//        let error = errorJson["error"] as? [String: Any],
//        let message = error["message"] as? String
//      {
//        throw NSError(
//          domain: "GeminiAPI",
//          code: (response as? HTTPURLResponse)?.statusCode ?? 0,
//          userInfo: [NSLocalizedDescriptionKey: message])
//      }
//      throw URLError(.badServerResponse)
//    }
//
//    // Parse the response
//    guard
//      let json = try? JSONSerialization.jsonObject(with: data)
//        as? [String: Any],
//      let candidates = json["candidates"] as? [[String: Any]],
//      let firstCandidate = candidates.first,
//      let content = firstCandidate["content"] as? [String: Any],
//      let parts = content["parts"] as? [[String: Any]],
//      let firstPart = parts.first,
//      let text = firstPart["text"] as? String
//    else {
//      throw NSError(
//        domain: "GeminiAPI", code: 0,
//        userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
//    }
//
//    return text
//  }
//}
//
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView()
//  }
//}

import SwiftUI
import Combine

// MARK: - Data Models

struct Paper: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let abstract: String
    let authors: [String]
    let url: String
    let year: Int
    let venue: String
    
    static func == (lhs: Paper, rhs: Paper) -> Bool {
        return lhs.id == rhs.id
    }
}

class UserPreferences: ObservableObject {
    @Published var likedTopics: [String] = []
    @Published var dislikedTopics: [String] = []
    @Published var viewedPapers: Set<String> = []
    @Published var searchHistory: [String] = []
    
    func addLikedTopic(_ topic: String) {
        likedTopics.append(topic)
    }
    
    func addDislikedTopic(_ topic: String) {
        dislikedTopics.append(topic)
    }
    
    func markPaperAsViewed(_ paperId: String) {
        viewedPapers.insert(paperId)
    }
    
    func hasViewedPaper(_ paperId: String) -> Bool {
        return viewedPapers.contains(paperId)
    }
    
    func addSearchQuery(_ query: String) {
        searchHistory.append(query)
    }
}

class RecommendationEngine: ObservableObject {
    @Published var recommendedPapers: [Paper] = []
    private var userPreferences: UserPreferences
    private var model: GenerativeModel
    private var cancellables = Set<AnyCancellable>()
    
    init(userPreferences: UserPreferences, model: GenerativeModel) {
        self.userPreferences = userPreferences
        self.model = model
        
        // Set up subscription to refresh recommendations when preferences change
        userPreferences.$likedTopics
            .combineLatest(userPreferences.$dislikedTopics, userPreferences.$searchHistory)
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.generateRecommendations()
            }
            .store(in: &cancellables)
    }
    
    func generateRecommendations() {
        Task {
            await fetchRecommendations()
        }
    }
    
    private func fetchRecommendations() async {
        // Build a prompt for Gemini based on user preferences
        let prompt = buildRecommendationPrompt()
        
        do {
            let response = try await model.generateContent(prompt)
            
            // Parse the response to extract paper IDs or topics
            let topics = parseTopicsFromResponse(response)
            
            // Fetch actual papers based on these topics
            for topic in topics {
                if let papers = await fetchPapersForTopic(topic) {
                    // Filter out already viewed papers
                    let newPapers = papers.filter { !userPreferences.hasViewedPaper($0.id) }
                    
                    DispatchQueue.main.async {
                        self.recommendedPapers.append(contentsOf: newPapers)
                    }
                }
            }
        } catch {
            print("Error generating recommendations: \(error)")
        }
    }
    
    private func buildRecommendationPrompt() -> String {
        var prompt = "Generate 5 academic research topics based on the following preferences:"
        
        if !userPreferences.likedTopics.isEmpty {
            prompt += "\nTopics the user likes: \(userPreferences.likedTopics.joined(separator: ", "))"
        }
        
        if !userPreferences.dislikedTopics.isEmpty {
            prompt += "\nTopics the user dislikes: \(userPreferences.dislikedTopics.joined(separator: ", "))"
        }
        
        if !userPreferences.searchHistory.isEmpty {
            prompt += "\nRecent searches: \(userPreferences.searchHistory.joined(separator: ", "))"
        }
        
        prompt += "\nPlease return exactly 5 specific research topics, one per line. Be diverse but relevant to the user's interests."
        
        return prompt
    }
    
    private func parseTopicsFromResponse(_ response: String) -> [String] {
        // Split the response by newlines and take up to 5 topics
        return response.split(separator: "\n")
            .prefix(5)
            .map { String($0) }
    }
    
    private func fetchPapersForTopic(_ topic: String) async -> [Paper]? {
        guard let encodedQuery = topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let urlString = "https://api.semanticscholar.org/graph/v1/paper/search?query=\(encodedQuery)&fields=paperId,title,abstract,authors,url,year,venue&limit=2"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]] {
                
                return dataArray.compactMap { paperJson -> Paper? in
                    guard let paperId = paperJson["paperId"] as? String,
                          let title = paperJson["title"] as? String else {
                        return nil
                    }
                    
                    let abstract = paperJson["abstract"] as? String ?? "No abstract available"
                    let authorsData = paperJson["authors"] as? [[String: Any]] ?? []
                    let authors = authorsData.compactMap { $0["name"] as? String }
                    let url = paperJson["url"] as? String ?? ""
                    let year = paperJson["year"] as? Int ?? 0
                    let venue = paperJson["venue"] as? String ?? ""
                    
                    return Paper(
                        id: paperId,
                        title: title,
                        abstract: abstract,
                        authors: authors,
                        url: url,
                        year: year,
                        venue: venue
                    )
                }
            }
            return nil
        } catch {
            print("Error fetching papers: \(error)")
            return nil
        }
    }
    
    func getNextBatch(count: Int = 5) {
        Task {
            await fetchRecommendations()
        }
    }
}

// MARK: - UI Components

struct CardView: View {
    let paper: Paper
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    @State private var showDetails = false
    
    var onSwipe: (Paper, Bool) -> Void
    
    enum SwipeStatus {
        case none
        case like
        case dislike
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(paper.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text(paper.authors.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(paper.abstract)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(showDetails ? nil : 3)
            
            if !showDetails {
                Button("Show more") {
                    withAnimation {
                        showDetails = true
                    }
                }
                .foregroundColor(.purple)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Year: \(paper.year)")
                        .font(.caption)
                    
                    Text("Venue: \(paper.venue)")
                        .font(.caption)
                    
                    Button("Show less") {
                        withAnimation {
                            showDetails = false
                        }
                    }
                    .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 8)
        )
        .overlay(
            // Like/Dislike Indicator
            Group {
                if swipeStatus == .like {
                    HStack {
                        Spacer()
                        Text("Interested")
                            .font(.headline)
                            .padding(10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.trailing, 16)
                    }
                } else if swipeStatus == .dislike {
                    HStack {
                        Text("Not Interested")
                            .font(.headline)
                            .padding(10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.leading, 16)
                        Spacer()
                    }
                }
            }
        )
        .offset(x: translation.width, y: 0)
        .rotationEffect(.degrees(Double(translation.width / 25)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    translation = value.translation
                    
                    // Update swipe status based on translation
                    if translation.width > 50 {
                        swipeStatus = .like
                    } else if translation.width < -50 {
                        swipeStatus = .dislike
                    } else {
                        swipeStatus = .none
                    }
                }
                .onEnded { value in
                    // Handle card swipe
                    if translation.width > 100 {
                        // Swiped right - like
                        withAnimation {
                            translation.width = 500
                        }
                        onSwipe(paper, true)
                    } else if translation.width < -100 {
                        // Swiped left - dislike
                        withAnimation {
                            translation.width = -500
                        }
                        onSwipe(paper, false)
                    } else {
                        // Reset position
                        withAnimation {
                            translation = .zero
                            swipeStatus = .none
                        }
                    }
                }
        )
        .animation(.spring(), value: translation)
    }
}

struct HomeView: View {
    @ObservedObject var recommendationEngine: RecommendationEngine
    @ObservedObject var userPreferences: UserPreferences
    @State private var currentIndex = 0
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if recommendationEngine.recommendedPapers.isEmpty {
                VStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(2)
                            .padding()
                        Text("Generating recommendations...")
                            .font(.headline)
                    } else {
                        Text("Welcome! Swipe cards to see more recommendations.")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Load Recommendations") {
                            loadRecommendations()
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                // Card Stack
                ZStack {
                    // We'll display the top 3 cards (if available)
                    ForEach(0..<min(3, recommendationEngine.recommendedPapers.count - currentIndex), id: \.self) { i in
                        let index = currentIndex + i
                        if index < recommendationEngine.recommendedPapers.count {
                            let paper = recommendationEngine.recommendedPapers[index]
                            CardView(paper: paper) { paper, isLiked in
                                handleSwipe(paper: paper, isLiked: isLiked)
                            }
                            .stacked(at: i, in: 3)
                        }
                    }
                }
                .padding()
                
                // Loading indicator for next batch
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                        Spacer().frame(height: 100)
                    }
                }
            }
        }
        .onAppear {
            loadRecommendations()
        }
    }
    
    private func loadRecommendations() {
        isLoading = true
        recommendationEngine.generateRecommendations()
        
        // Simulate async loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
    
    private func handleSwipe(paper: Paper, isLiked: Bool) {
        // Extract topics from the paper title and abstract
        let paperContent = paper.title + " " + paper.abstract
        let topicKeywords = extractKeywords(from: paperContent)
        
        // Update user preferences
        if isLiked {
            for topic in topicKeywords {
                userPreferences.addLikedTopic(topic)
            }
        } else {
            for topic in topicKeywords {
                userPreferences.addDislikedTopic(topic)
            }
        }
        
        // Mark paper as viewed
        userPreferences.markPaperAsViewed(paper.id)
        
        // Move to next card
        withAnimation {
            currentIndex += 1
        }
        
        // If we're running out of cards, get more
        if recommendationEngine.recommendedPapers.count - currentIndex < 3 {
            isLoading = true
            recommendationEngine.getNextBatch()
            
            // Simulate async loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    private func extractKeywords(from text: String) -> [String] {
        // Simple keyword extraction - in a real app, you might use NLP
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let stopWords = ["the", "and", "or", "a", "an", "in", "on", "at", "to", "for", "with", "by", "about", "as", "of"]
        
        return words
            .filter { word in
                let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
                return cleaned.count > 3 && !stopWords.contains(cleaned)
            }
            .prefix(5)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
    }
}

struct SearchView: View {
    @ObservedObject var userPreferences: UserPreferences
    @State private var searchText = ""
    @State private var searchResults: [Paper] = []
    @State private var isSearching = false
    
    let model: GenerativeModel
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                TextField("Search for topics", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: performSearch) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.purple)
                        .padding(10)
                }
            }
            .padding()
            
            if isSearching {
                ProgressView("Searching...")
                    .padding()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                Text("No results found")
                    .padding()
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(searchResults) { paper in
                            SearchResultCard(paper: paper)
                                .onAppear {
                                    // Mark as viewed when the user sees it
                                    userPreferences.markPaperAsViewed(paper.id)
                                }
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
    }
    
    func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        
        // Save search query to user preferences
        userPreferences.addSearchQuery(searchText)
        
        // Fetch search results from Semantic Scholar
        Task {
            if let papers = await fetchPapersForTopic(searchText) {
                DispatchQueue.main.async {
                    self.searchResults = papers
                    self.isSearching = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isSearching = false
                }
            }
        }
    }
    
    private func fetchPapersForTopic(_ topic: String) async -> [Paper]? {
        guard let encodedQuery = topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let urlString = "https://api.semanticscholar.org/graph/v1/paper/search?query=\(encodedQuery)&fields=paperId,title,abstract,authors,url,year,venue&limit=10"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]] {
                
                return dataArray.compactMap { paperJson -> Paper? in
                    guard let paperId = paperJson["paperId"] as? String,
                          let title = paperJson["title"] as? String else {
                        return nil
                    }
                    
                    let abstract = paperJson["abstract"] as? String ?? "No abstract available"
                    let authorsData = paperJson["authors"] as? [[String: Any]] ?? []
                    let authors = authorsData.compactMap { $0["name"] as? String }
                    let url = paperJson["url"] as? String ?? ""
                    let year = paperJson["year"] as? Int ?? 0
                    let venue = paperJson["venue"] as? String ?? ""
                    
                    return Paper(
                        id: paperId,
                        title: title,
                        abstract: abstract,
                        authors: authors,
                        url: url,
                        year: year,
                        venue: venue
                    )
                }
            }
            return nil
        } catch {
            print("Error fetching papers: \(error)")
            return nil
        }
    }
}

struct SearchResultCard: View {
    let paper: Paper
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(paper.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(paper.authors.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            if showDetails {
                Text(paper.abstract)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Year: \(paper.year)")
                            .font(.caption)
                        Text("Venue: \(paper.venue)")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: paper.url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "link")
                            .foregroundColor(.purple)
                    }
                    .disabled(paper.url.isEmpty)
                }
                
                Button("Show less") {
                    withAnimation {
                        showDetails = false
                    }
                }
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
            } else {
                Text(paper.abstract)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Button("Show more") {
                    withAnimation {
                        showDetails = true
                    }
                }
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
        )
    }
}

// MARK: - Helper Extensions

extension View {
    // Create stacked card effect
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position) * 10
        return self
            .offset(x: 0, y: offset)
            .scaleEffect(1.0 - CGFloat(position) * 0.05)
            .zIndex(Double(total - position))
    }
}

// MARK: - Main App Structure

struct MainAppView: View {
    @StateObject private var userPreferences = UserPreferences()
    
    private let model = GenerativeModel(
        name: "gemini-1.5-pro",
        apiKey: "key"
    )
    
    @StateObject private var recommendationEngine: RecommendationEngine
    
    init() {
        let preferences = UserPreferences()
        let model = GenerativeModel(
            name: "gemini-1.5-pro",
            apiKey: "key"
        )
        
        _userPreferences = StateObject(wrappedValue: preferences)
        _recommendationEngine = StateObject(wrappedValue: RecommendationEngine(userPreferences: preferences, model: model))
    }
    
    var body: some View {
        TabView {
            // Home view with recommendations
            HomeView(recommendationEngine: recommendationEngine, userPreferences: userPreferences)
                .tabItem {
                    Label("Discover", systemImage: "square.stack")
                }
            
            // Search view
            SearchView(userPreferences: userPreferences, model: model)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
        .accentColor(.purple)
    }
}

struct GenerativeModel {
  let name: String
  let apiKey: String
  let baseURL = "https://generativelanguage.googleapis.com"

  // Generation configuration
  var temperature: Double = 0.2
  var maxOutputTokens: Int = 1024
  var topK: Int = 40
  var topP: Double = 0.95

  func generateContent(_ prompt: String) async throws -> String {
    let endpoint = "\(baseURL)/v1/models/\(name):generateContent?key=\(apiKey)"

    guard let url = URL(string: endpoint) else {
      throw URLError(.badURL)
    }

    // Create the request payload
    let requestBody: [String: Any] = [
      "contents": [
        [
          "role": "user",
          "parts": [
            ["text": prompt]
          ],
        ]
      ],
      "generationConfig": [
        "temperature": temperature,
        "maxOutputTokens": maxOutputTokens,
        "topK": topK,
        "topP": topP,
      ],
    ]

    // Create and configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

    // Send the request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Check the response status code
    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      // Try to extract error message if available
      if let errorJson = try? JSONSerialization.jsonObject(with: data)
        as? [String: Any],
        let error = errorJson["error"] as? [String: Any],
        let message = error["message"] as? String
      {
        throw NSError(
          domain: "GeminiAPI",
          code: (response as? HTTPURLResponse)?.statusCode ?? 0,
          userInfo: [NSLocalizedDescriptionKey: message])
      }
      throw URLError(.badServerResponse)
    }

    // Parse the response
    guard
      let json = try? JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      let candidates = json["candidates"] as? [[String: Any]],
      let firstCandidate = candidates.first,
      let content = firstCandidate["content"] as? [String: Any],
      let parts = content["parts"] as? [[String: Any]],
      let firstPart = parts.first,
      let text = firstPart["text"] as? String
    else {
      throw NSError(
        domain: "GeminiAPI", code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
    }

    return text
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
