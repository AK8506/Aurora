//
//  ContentView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var apiOutput = ""

    var body: some View {
        VStack {
            TextField("Enter text", text: $inputText)
                .padding()
                .border(Color.gray, width: 1)

            Button("Fetch Data") {
                fetchDataFromAPI()
            }
            .padding()

            Text(apiOutput)
                .padding()
        }
        .padding()
    }

    func fetchDataFromAPI() {
        // API call will go here
        // For demonstration, simulating API response
        apiOutput = "Simulated API response for: \(inputText)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
