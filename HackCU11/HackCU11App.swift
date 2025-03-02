//
//  HackCU11App.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//

import SwiftUI


@main
struct HackCU11App: App {
    @StateObject var preferences = UserPreferences()
        var body: some Scene {
            WindowGroup {
                ForYouView(preferences: preferences)
            }
        }
}
