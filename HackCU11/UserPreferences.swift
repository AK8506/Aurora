//
//  UserPreferences.swift
//  HackCU11
//
//  Created by SohanBekkam on 3/1/25.
//

import Combine
import SwiftUI

class UserPreferences: ObservableObject {
  @Published var likedTopics: [String] = []
  @Published var dislikedTopics: [String] = []
  @Published var savedTopics: [(title: String, content: String)] = []

  func like(_ topic: String) {
    // Add to liked topics if not already there
    if !likedTopics.contains(topic) {
      likedTopics.append(topic)
    }
  }

  func dislike(_ topic: String) {
    // Add to disliked topics if not already there
    if !dislikedTopics.contains(topic) {
      dislikedTopics.append(topic)
    }
  }

  func saveTopic(title: String, content: String) {
    if !savedTopics.contains(where: { $0.title == title }) {
      savedTopics.append((title, content))
    }
  }
}
