//
//  UserPreferences.swift
//  HackCU11
//
//  Created by SohanBekkam on 3/1/25.
//

import SwiftUI
import Combine

class UserPreferences: ObservableObject {
    @Published var likedTopics: [String] = []
    @Published var dislikedTopics: [String] = []
    
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
}
