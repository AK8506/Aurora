//
//  ForYouView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//

//import SwiftUI
//
//struct ForYouView: View {
//    @State private var topics: [(title: String, content: String)] = []
//    @State private var isLoading = false
//    let model = GenerativeModel(
//        name: "gemini-1.5-pro",
//        apiKey: "key"
//    )
//    
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Fetching Topics...")
//                    .padding()
//            } else if !topics.isEmpty {
//                TabView {
//                    ForEach(topics, id: \.title) { topic in
//                        CardView(title: topic.title, content: topic.content)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//            } else {
//                Text("No topics available. Try refreshing.")
//                    .padding()
//            }
//            
//            Button(action: {
//                Task {
//                    await fetchRandomTopics()
//                }
//            }) {
//                Text("Get New Topics")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.purple)
//                    .cornerRadius(10)
//            }
//            .padding()
//        }
//        .onAppear {
//            Task {
//                await fetchRandomTopics()
//            }
//        }
//    }
//    
//    func fetchRandomTopics() async {
//        isLoading = true
//        defer { isLoading = false }
//        
//        let prompt = "Generate three interesting research topics with a brief summary."
//        do {
//            let response = try await model.generateContent(prompt)
//            parseTopics(from: response)
//        } catch {
//            print("Error fetching topics: \(error.localizedDescription)")
//        }
//    }
//    
//    func parseTopics(from response: String) {
//        let lines = response.components(separatedBy: "\n\n")
//        topics = lines.compactMap { line in
//            let parts = line.components(separatedBy: "\n")
//            guard parts.count > 1 else { return nil }
//            return (title: parts[0], content: parts.dropFirst().joined(separator: " "))
//        }
//    }
//}
//
//struct ForYouView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouView()
//    }
//}
//
//import SwiftUI
//
//struct ForYouView: View {
//    @State private var topicTitle = ""
//    @State private var topicContent = ""
//    @State private var isLoading = false
//    
//    let model = GenerativeModel(
//        name: "gemini-1.5-pro",
//        apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
//    )
//    
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Fetching topic...")
//                    .padding()
//            } else {
//                CardView(title: topicTitle, content: topicContent)
//            }
//            
//            Button(action: {
//                Task { await fetchRandomTopic() }
//            }) {
//                Text("Get New Topic")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.purple)
//                    .cornerRadius(10)
//                    .shadow(radius: 3)
//            }
//            .padding()
//        }
//        .onAppear {
//            Task { await fetchRandomTopic() } // Load topic on view appearance
//        }
//    }
//    
//    func fetchRandomTopic() async {
//        isLoading = true
//        let prompt = "Generate a random academic research topic and provide a brief description."
//        do {
//            let response = try await model.generateContent(prompt)
//            let splitResponse = response.components(separatedBy: "\n\n")
//            topicTitle = splitResponse.first ?? "Random Topic"
//            topicContent = splitResponse.dropFirst().joined(separator: "\n\n")
//        } catch {
//            topicTitle = "Error"
//            topicContent = "Failed to fetch topic: \(error.localizedDescription)"
//        }
//        isLoading = false
//    }
//}
//
//struct ForYouView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouView()
//    }
//}


import SwiftUI

struct ForYouView: View {
    // Observed preferences so we can incorporate likes/dislikes into Gemini prompts
    @ObservedObject var preferences: UserPreferences
    
    @State private var currentTopic: (title: String, content: String)? = nil
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    let model = GenerativeModel(
        name: "gemini-1.5-pro",
        apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
    )
    
    var body: some View {
        ZStack {
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
    
    // MARK: - Swipe Handling
    func handleSwipe(didLike: Bool, topic: String) {
        // If user swiped right, they like it
        if didLike {
            preferences.like(topic)
        } else {
            preferences.dislike(topic)
        }
        
        // After the swipe, fetch a new topic
        Task {
            await fetchNextTopic()
        }
    }
    
    // MARK: - Fetch Next Topic from Gemini
    func fetchNextTopic() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = ""
        
        // Build a prompt that includes the user’s preferences
        let likes = preferences.likedTopics.isEmpty ? "none" : preferences.likedTopics.joined(separator: ", ")
        let dislikes = preferences.dislikedTopics.isEmpty ? "none" : preferences.dislikedTopics.joined(separator: ", ")
        
        let prompt = """
        You are a recommendation system. The user likes topics: \(likes). The user dislikes topics: \(dislikes).
        Suggest ONE new academic research topic that aligns more with the user’s likes and avoids the user’s dislikes.
        Provide a short, paragraph-long summary of that topic. Return the title on one line, then a blank line, then the summary.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            // We'll assume the response has two sections: the first line is the title, the second is the content
            let parts = response.components(separatedBy: "\n\n")
            let title = parts.first ?? "Untitled"
            let content = parts.dropFirst().joined(separator: "\n\n")
            
            // Update current topic
            currentTopic = (title: title, content: content.isEmpty ? "No summary." : content)
            
        } catch {
            errorMessage = "Failed to fetch topic: \(error.localizedDescription)"
        }
    }
}

//struct ForYouView_Previews: PreviewProvider {
//    static var previews: some View {
//        ForYouView(preferences: <#T##UserPreferences#>)
//    }
//}
