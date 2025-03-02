//
//  ContentView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
// AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns

import SwiftUI

struct HomeView: View {
    @State private var inputText = ""
    @State private var apiOutput = ""
    @State private var isLoading = false
    @State private var currTitle = ""
    
    let model = GenerativeModel(
        name: "gemini-1.5-pro",
        apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
    )

    var body: some View {
        VStack {
            // Input field with search icon
            HStack {
                TextField("Enter Semantic Scholar ID or Topic", text: $inputText)
                    .padding(.vertical, 10)
                    .padding(.leading, 40)
                    .background(Color.clear)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.purple)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    )
                    .padding(.horizontal)
            }

            // Underline for input field
            Rectangle()
                .frame(height: 2)
                .foregroundColor(.purple)
                .padding(.bottom, 15)

            // Fetch data button
            Button(action: {
                Task {
                    isLoading = true
                    await fetchDataFromAPI()
                    isLoading = false
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                } else {
                    Text("Fetch Data")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal, 16)
            .disabled(isLoading)

            // Display CardView with fetched data
            if !apiOutput.isEmpty {
                CardView(title: currTitle, content: apiOutput)
            }

            Spacer()
        }
        .padding()
    }

    // Function to fetch data from API
    func fetchDataFromAPI() async {
        if inputText.hasPrefix("ARXIV:") || inputText.count == 40 {
            await fetchFromSemanticScholarByID()
        } else {
            await fetchFromSemanticScholarBySearch()
        }
    }

    // Fetch by ID
    func fetchFromSemanticScholarByID() async {
        let urlString = "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,abstract,authors,url,year,venue"
        guard let url = URL(string: urlString) else {
            apiOutput = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: [String]] = ["ids": [inputText]]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]], let firstPaper = json.first {
                let (title, formattedOutput) = formatSemanticScholarResponse(paper: firstPaper)
                currTitle = title
                let geminiPrompt = "Summarize the following paper information in 3 sentences: \(formattedOutput)"
                await processWithGemini(prompt: geminiPrompt)
            } else {
                apiOutput = "Could not parse response."
            }
        } catch {
            apiOutput = "Error fetching data: \(error)"
        }
    }

    // Fetch by search
    func fetchFromSemanticScholarBySearch() async {
        guard let encodedQuery = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            apiOutput = "Invalid search query."
            return
        }

        let urlString = "https://api.semanticscholar.org/graph/v1/paper/search?query=\(encodedQuery)&fields=title,abstract,authors,url,year,venue"
        guard let url = URL(string: urlString) else {
            apiOutput = "Invalid URL."
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let dataArray = json["data"] as? [[String: Any]], let firstPaper = dataArray.first {
                let (title, formattedOutput) = formatSemanticScholarResponse(paper: firstPaper)
                currTitle = title
                let geminiPrompt = "Summarize the following paper information in 3 sentences: \(formattedOutput)"
                await processWithGemini(prompt: geminiPrompt)
            } else {
                apiOutput = "Could not parse response."
            }
        } catch {
            apiOutput = "Error fetching data: \(error)"
        }
    }

    // Format the response
    func formatSemanticScholarResponse(paper: [String: Any]) -> (String, String) {
        let title = paper["title"] as? String ?? "No Title"
        let abstract = paper["abstract"] as? String ?? "No Abstract"
        let authors = (paper["authors"] as? [[String: String]])?.compactMap { $0["name"] }.joined(separator: ", ") ?? "No Authors"
        let url = paper["url"] as? String ?? "No URL"
        let year = paper["year"] as? Int ?? 0
        let venue = paper["venue"] as? String ?? "No Venue"

        let formattedOutput = """
        Title: \(title)
        
        Abstract: \(abstract)
        
        Authors: \(authors)
        
        URL: \(url)
        
        Year: \(year)
        
        Venue: \(venue)
        """

        return (title, formattedOutput)
    }

    // Process the data using the Gemini API
    func processWithGemini(prompt: String) async {
        do {
            let response = try await model.generateContent(prompt)
            apiOutput = response
        } catch {
            apiOutput = "Gemini API error: \(error.localizedDescription)"
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
