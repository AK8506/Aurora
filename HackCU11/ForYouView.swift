//
//  ForYouView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//
// Akshay:  AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns
// Sohan:   AIzaSyB_qxzPhvouxFbHn8vGPNopyNDIsxaTRhc
// Sohan2: AIzaSyDPzmFnladufje-IDp5RyUJdC_Nf1xvOVQ

//
//import SwiftUI
//
//struct Topic: Codable {
//    let title: String
//    let content: String
//}
//
//struct ForYouView: View {
//    @ObservedObject var preferences: UserPreferences
//    @State private var currentTopic: (title: String, content: String)? = nil
//    @State private var topicQueue: [(title: String, content: String)] = []
//    @State private var isLoading = false
//    @State private var errorMessage = ""
//
//    let model = GenerativeModel(
//        name: "gemini-1.5-pro",
//        apiKey: "AIzaSyB_qxzPhvouxFbHn8vGPNopyNDIsxaTRhc"
//    )
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if isLoading {
//                    ProgressView("Loading your recommendation...")
//                        .padding()
//                } else if let topic = currentTopic {
//                    SwipeableCardView(
//                        title: topic.title,
//                        content: topic.content
//                    ) { didLike in
//                        handleSwipe(didLike: didLike, topic: topic.title)
//                    }
//                } else if !errorMessage.isEmpty {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                } else {
//                    Text("No content yet. Please wait...")
//                        .padding()
//                }
//            }
//            .onAppear {
//                Task {
//                    await fetchNextTopic()
//                }
//            }
//            .padding()
//            .navigationTitle("For You")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: LookupView()) {
//                        Text("Look Up")
//                            .foregroundColor(.purple)
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.purple)
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Handle Swiping
//    func handleSwipe(didLike: Bool, topic: String) {
//        if didLike {
//            preferences.like(topic)
//        } else {
//            preferences.dislike(topic)
//        }
//
//        // Remove current topic and fetch the next one
//        currentTopic = nil
//        Task {
//            await fetchNextTopic()
//        }
//    }
//
//    // MARK: - Fetch Next Topic
//    func fetchNextTopic() async {
//        isLoading = true
//        errorMessage = ""
//
//        // If the queue has topics, use one
//        if !topicQueue.isEmpty {
//            currentTopic = topicQueue.removeFirst()
//            isLoading = false
//            return
//        }
//
//        print("⚡ Fetching a new batch of topics...")
//        await batchProduceTopics()
//
//        if let nextTopic = topicQueue.first {
//            print("✅ Loaded topic: \(nextTopic.title)")
//            currentTopic = nextTopic
//            topicQueue.removeFirst()
//        } else {
//            errorMessage = "No topics available."
//        }
//
//        isLoading = false
//    }
//
//    // MARK: - Fetch a Batch of Topics
//  func batchProduceTopics() async {
//      let likes = preferences.likedTopics.isEmpty ? "none" : preferences.likedTopics.joined(separator: ", ")
//      let dislikes = preferences.dislikedTopics.isEmpty ? "none" : preferences.dislikedTopics.joined(separator: ", ")
//
//      let prompt = """
//      You are a recommendation system. The user likes topics: \(likes). The user dislikes topics: \(dislikes).
//      Suggest exactly FIVE new academic research topics in **JSON format only** with no extra text.
//      
//      JSON format:
//      [
//          {
//              "title": "Topic Title",
//              "content": "A 150-word summary."
//          },
//          ...
//      ]
//      
//      **Return only valid JSON and nothing else. Do not include explanations or any other text.**
//      """
//
//    do {
//        let response = try await model.generateContent(prompt)
//        print("📥 Raw Gemini Response:\n\(response)")
//
//        // Extract JSON manually using rangeOf
//        if let jsonStart = response.range(of: "[")?.lowerBound,
//           let jsonEnd = response.range(of: "]", options: .backwards)?.upperBound {
//            let jsonString = String(response[jsonStart..<jsonEnd])
//            print("✅ Extracted JSON:\n\(jsonString)")
//
//            guard let jsonData = jsonString.data(using: .utf8) else {
//                errorMessage = "Invalid JSON encoding."
//                return
//            }
//
//            let decoder = JSONDecoder()
//            let topics = try decoder.decode([Topic].self, from: jsonData)
//
//            if topics.isEmpty {
//                errorMessage = "No topics received."
//                return
//            }
//
//            topicQueue = topics.map { ($0.title, $0.content) }
//            print("📌 Loaded \(topicQueue.count) topics.")
//
//        } else {
//            errorMessage = "Failed to extract JSON from response."
//        }
//
//    } catch {
//        errorMessage = "Failed to fetch topics: \(error.localizedDescription)"
//        print("❌ JSON Decoding Error: \(error.localizedDescription)")
//    }
//
//  }
//
//}
//
//
//
//
//struct ForYouView_Previews: PreviewProvider {
//  static var previews: some View {
//    ForYouView(preferences: UserPreferences())
//  }
//}

//
//import SwiftUI
//
//struct Topic: Codable {
//    let title: String
//    let content: String
//}
//
//struct ForYouView: View {
//    @ObservedObject var preferences: UserPreferences
//    @State private var currentTopic: (title: String, content: String)? = nil
//    @State private var topicQueue: [(title: String, content: String)] = []
//    @State private var isLoading = false
//    @State private var errorMessage = ""
//
//    let model = GenerativeModel(
//        name: "gemini-1.5-pro",
//        apiKey: "key"
//    )
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // A more visible linear gradient as background
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        .purple.opacity(0.2),.blue.opacity(0.2)     // a more saturated blue
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea(.all)
//
//                VStack {
//                    if isLoading {
//                        ProgressView("Loading your recommendation...")
//                            .padding()
//                    } else if let topic = currentTopic {
//                        SwipeableCardView(
//                            title: topic.title,
//                            content: topic.content
//                        ) { didLike in
//                            handleSwipe(didLike: didLike, topic: topic.title)
//                        }
//                    } else if !errorMessage.isEmpty {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .padding()
//                    } else {
//                        Text("No content yet. Please wait...")
//                            .padding()
//                    }
//                }
//                .onAppear {
//                    Task {
//                        await fetchNextTopic()
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("For You")
//            .navigationBarTitleDisplayMode(.inline)
//            // Remove the default navigation bar background so our gradient is visible
//            .toolbarBackground(.clear, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: LookupView()) {
//                        Text("Look Up")
//                            .foregroundColor(.purple)
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.purple)
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Handle Swiping
//    func handleSwipe(didLike: Bool, topic: String) {
//        if didLike {
//            preferences.like(topic)
//        } else {
//            preferences.dislike(topic)
//        }
//
//        // Remove current topic and fetch the next one
//        currentTopic = nil
//        Task {
//            await fetchNextTopic()
//        }
//    }
//
//    // MARK: - Fetch Next Topic
//    func fetchNextTopic() async {
//        isLoading = true
//        errorMessage = ""
//
//        // If the queue has topics, use one
//        if !topicQueue.isEmpty {
//            currentTopic = topicQueue.removeFirst()
//            isLoading = false
//            return
//        }
//
//        print("⚡ Fetching a new batch of topics...")
//        await batchProduceTopics()
//
//        if let nextTopic = topicQueue.first {
//            print("✅ Loaded topic: \(nextTopic.title)")
//            currentTopic = nextTopic
//            topicQueue.removeFirst()
//        } else {
//            errorMessage = "No topics available."
//        }
//
//        isLoading = false
//    }
//
//    // MARK: - Fetch a Batch of Topics
//    func batchProduceTopics() async {
//        let likes = preferences.likedTopics.isEmpty
//            ? "none"
//            : preferences.likedTopics.joined(separator: ", ")
//        let dislikes = preferences.dislikedTopics.isEmpty
//            ? "none"
//            : preferences.dislikedTopics.joined(separator: ", ")
//
//        let prompt = """
//        You are a recommendation system. The user likes topics: \(likes). The user dislikes topics: \(dislikes).
//        Suggest exactly FIVE new academic research topics in **JSON format only** with no extra text.
//
//        JSON format:
//        [
//            {
//                "title": "Topic Title",
//                "content": "A 150-word summary."
//            },
//            ...
//        ]
//
//        **Return only valid JSON and nothing else. Do not include explanations or any other text.**
//        """
//
//        do {
//            let response = try await model.generateContent(prompt)
//            print("📥 Raw Gemini Response:\n\(response)")
//
//            // Extract JSON manually using range(of:)
//            if let jsonStart = response.range(of: "[")?.lowerBound,
//               let jsonEnd = response.range(of: "]", options: .backwards)?.upperBound {
//                let jsonString = String(response[jsonStart..<jsonEnd])
//                print("✅ Extracted JSON:\n\(jsonString)")
//
//                guard let jsonData = jsonString.data(using: .utf8) else {
//                    errorMessage = "Invalid JSON encoding."
//                    return
//                }
//
//                let decoder = JSONDecoder()
//                let topics = try decoder.decode([Topic].self, from: jsonData)
//
//                if topics.isEmpty {
//                    errorMessage = "No topics received."
//                    return
//                }
//
//                topicQueue = topics.map { ($0.title, $0.content) }
//                print("📌 Loaded \(topicQueue.count) topics.")
//
//            } else {
//                errorMessage = "Failed to extract JSON from response."
//            }
//
//        } catch {
//            errorMessage = "Failed to fetch topics: \(error.localizedDescription)"
//            print("❌ JSON Decoding Error: \(error.localizedDescription)")
//        }
//    }
//}
//
//struct ForYouView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouView(preferences: UserPreferences())
//    }
//}


import SwiftUI

struct Topic: Codable {
    let title: String
    let content: String
}

struct ForYouView: View {
    @ObservedObject var preferences: UserPreferences
    @State private var currentTopic: (title: String, content: String)? = nil
    @State private var topicQueue: [(title: String, content: String)] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    let model = GenerativeModel(
        name: "gemini-1.5-pro",
        apiKey: "AIzaSyDPzmFnladufje-IDp5RyUJdC_Nf1xvOVQ"
    )

    // MARK: - Custom init to make NavBar background transparent
    init(preferences: UserPreferences) {
        _preferences = ObservedObject(initialValue: preferences)

        let appearance = UINavigationBarAppearance()
        // Make background fully transparent
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear

        // Apply to both standard (inline) and scroll-edge (large title) appearances
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Lighter gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.3),
                        Color.blue.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all) // Extend under status bar & nav bar

                VStack {
                    if isLoading {
                        ProgressView("Loading your recommendation...")
                            .padding()
                    } else if let topic = currentTopic {
                        SwipeableCardView(
                            title: topic.title,
                            content: topic.content
                        ) { didLike in
                            handleSwipe(didLike: didLike, topic: topic.title)
                        }
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("No content yet. Please wait...")
                            .padding()
                    }
                }
                .onAppear {
                    Task {
                        await fetchNextTopic()
                    }
                }
                .padding()
            }
            .navigationTitle("For You")
            .navigationBarTitleDisplayMode(.inline)
            // Because we used the custom init, we do NOT need .toolbarBackground(.clear)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: LookupView()) {
                        Text("Look Up")
                            .foregroundColor(.purple)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }

    // MARK: - Handle Swiping
    func handleSwipe(didLike: Bool, topic: String) {
        if didLike {
            preferences.like(topic)
        } else {
            preferences.dislike(topic)
        }

        // Remove current topic and fetch the next one
        currentTopic = nil
        Task {
            await fetchNextTopic()
        }
    }

    // MARK: - Fetch Next Topic
    func fetchNextTopic() async {
        isLoading = true
        errorMessage = ""

        // If the queue has topics, use one
        if !topicQueue.isEmpty {
            currentTopic = topicQueue.removeFirst()
            isLoading = false
            return
        }

        print("⚡ Fetching a new batch of topics...")
        await batchProduceTopics()

        if let nextTopic = topicQueue.first {
            print("✅ Loaded topic: \(nextTopic.title)")
            currentTopic = nextTopic
            topicQueue.removeFirst()
        } else {
            errorMessage = "No topics available."
        }

        isLoading = false
    }

    // MARK: - Fetch a Batch of Topics
    func batchProduceTopics() async {
        let likes = preferences.likedTopics.isEmpty
            ? "none"
            : preferences.likedTopics.joined(separator: ", ")
        let dislikes = preferences.dislikedTopics.isEmpty
            ? "none"
            : preferences.dislikedTopics.joined(separator: ", ")

        let prompt = """
        You are a recommendation system. The user likes topics: \(likes). The user dislikes topics: \(dislikes).
        Suggest exactly FIVE new academic research topics in **JSON format only** with no extra text.

        JSON format:
        [
            {
                "title": "Topic Title",
                "content": "A 150-word summary."
            },
            ...
        ]

        **Return only valid JSON and nothing else. Do not include explanations or any other text.**
        """

        do {
            let response = try await model.generateContent(prompt)
            print("📥 Raw Gemini Response:\n\(response)")

            // Extract JSON manually using range(of:)
            if let jsonStart = response.range(of: "[")?.lowerBound,
               let jsonEnd = response.range(of: "]", options: .backwards)?.upperBound {
                let jsonString = String(response[jsonStart..<jsonEnd])
                print("✅ Extracted JSON:\n\(jsonString)")

                guard let jsonData = jsonString.data(using: .utf8) else {
                    errorMessage = "Invalid JSON encoding."
                    return
                }

                let decoder = JSONDecoder()
                let topics = try decoder.decode([Topic].self, from: jsonData)

                if topics.isEmpty {
                    errorMessage = "No topics received."
                    return
                }

                topicQueue = topics.map { ($0.title, $0.content) }
                print("📌 Loaded \(topicQueue.count) topics.")

            } else {
                errorMessage = "Failed to extract JSON from response."
            }

        } catch {
            errorMessage = "Failed to fetch topics: \(error.localizedDescription)"
            print("❌ JSON Decoding Error: \(error.localizedDescription)")
        }
    }
}

struct ForYouView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView(preferences: UserPreferences())
    }
}
