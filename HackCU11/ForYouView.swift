//
//  ForYouView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//
// Akshay:  AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns
// Sohan:   AIzaSyB_qxzPhvouxFbHn8vGPNopyNDIsxaTRhc

import SwiftUI

struct ForYouView: View {
  @ObservedObject var preferences: UserPreferences
  @State private var currentTopic: (title: String, content: String)? = nil
  @State private var isLoading = false
  @State private var errorMessage = ""

  let model = GenerativeModel(
    name: "gemini-1.5-pro",
    apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
  )

  var body: some View {
    NavigationStack {
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
      .navigationTitle("For You")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {

            NavigationLink(destination: LookupView()) {
              Text("Look Up")  // Logo icon (change if needed)
                .foregroundColor(.purple)
              Image(systemName: "magnifyingglass")
                .foregroundColor(.purple)
            }
          }
        }
      }
    }
  }

  // MARK: - Swipe Handling
  func handleSwipe(didLike: Bool, topic: String) {
    if didLike {
      preferences.like(topic)
    } else {
      preferences.dislike(topic)
    }

    // Reset current topic before fetching the next one
    currentTopic = nil

    Task {
      await fetchNextTopic()
    }
  }

  // MARK: - Fetch Next Topic from Gemini
  func fetchNextTopic() async {
    isLoading = true
    currentTopic = nil
    defer { isLoading = false }
    errorMessage = ""

    let likes =
      preferences.likedTopics.isEmpty
      ? "none" : preferences.likedTopics.joined(separator: ", ")
    let dislikes =
      preferences.dislikedTopics.isEmpty
      ? "none" : preferences.dislikedTopics.joined(separator: ", ")

    let prompt = """
      You are a recommendation system. The user likes topics: \(likes). The user dislikes topics: \(dislikes).
      Suggest ONE random new academic research topic that aligns more with the user’s likes and avoids the user’s dislikes.
      Do not completely avoid topics the user dislikes, but rather show them it less often.
      The research topic you choose must be a random choice each time.
      Provide a short, paragraph-long summary of that topic. Return the title on one line, then a blank line, then the summary.
      Please limit responses to around 150 words.
      """

    do {
      let response = try await model.generateContent(prompt)
      let parts = response.components(separatedBy: "\n\n")
      guard let title = parts.first, !title.isEmpty else {
        errorMessage = "Invalid response format"
        return
      }
      let content = parts.dropFirst().joined(separator: "\n\n")

      currentTopic = (
        title: title, content: content.isEmpty ? "No summary." : content
      )

    } catch {
      errorMessage = "Failed to fetch topic: \(error.localizedDescription)"
    }
  }
}

struct ForYouView_Previews: PreviewProvider {
  static var previews: some View {
    ForYouView(preferences: UserPreferences())
  }
}
