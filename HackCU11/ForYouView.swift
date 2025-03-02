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

import SwiftUI

struct ForYouView: View {
    @State private var topicTitle = ""
    @State private var topicContent = ""
    @State private var isLoading = false
    
    let model = GenerativeModel(
        name: "gemini-1.5-pro",
        apiKey: "key"
    )
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching topic...")
                    .padding()
            } else {
                CardView(title: topicTitle, content: topicContent)
            }
            
            Button(action: {
                Task { await fetchRandomTopic() }
            }) {
                Text("Get New Topic")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
            .padding()
        }
        .onAppear {
            Task { await fetchRandomTopic() } // Load topic on view appearance
        }
    }
    
    func fetchRandomTopic() async {
        isLoading = true
        let prompt = "Generate a random academic research topic and provide a brief description."
        do {
            let response = try await model.generateContent(prompt)
            let splitResponse = response.components(separatedBy: "\n\n")
            topicTitle = splitResponse.first ?? "Random Topic"
            topicContent = splitResponse.dropFirst().joined(separator: "\n\n")
        } catch {
            topicTitle = "Error"
            topicContent = "Failed to fetch topic: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct ForYouView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
    }
}
