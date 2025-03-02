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

    let model = GenerativeModel(
        name: "gemini-pro",
        apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns",
        generationConfig: "{temperature=0.2}"
    )

    var body: some View {
        VStack {
            TextField("Enter Semantic Scholar ID or search query", text: $inputText)
                .padding()
                .border(Color.gray, width: 1)

            Button("Fetch Data") {
                Task {
                    await fetchDataFromAPI()
                }
            }
            .padding()

            ScrollView {
                Text(apiOutput)
                    .padding()
            }
        }
        .padding()
    }

    func fetchDataFromAPI() async {
        if inputText.hasPrefix("ARXIV:") || inputText.count == 40 {
            await fetchFromSemanticScholarByID()
        } else {
            await fetchFromSemanticScholarBySearch()
        }
    }

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
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                let firstPaper = json.first {
                let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
                let geminiPrompt = "Summarize the following paper information in 3 sentences: \(formattedOutput)"
                await processWithGemini(prompt: geminiPrompt)
            } else {
                apiOutput = "Could not parse Semantic Scholar response."
            }
        } catch {
            apiOutput = "Error fetching data from Semantic Scholar: \(error)"
        }
    }

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
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]],
               let firstPaper = dataArray.first {
                let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
                let geminiPrompt = "Summarize the following paper information in 3 sentences: \(formattedOutput)"
                await processWithGemini(prompt: geminiPrompt)
            } else {
                apiOutput = "Could not parse Semantic Scholar search response."
            }
        } catch {
            apiOutput = "Error fetching data from Semantic Scholar search: \(error)"
        }
    }

    func formatSemanticScholarResponse(paper: [String: Any]) -> String {
        let title = paper["title"] as? String ?? "No Title"
        let abstract = paper["abstract"] as? String ?? "No Abstract"
        let authors = (paper["authors"] as? [[String: String]])?.compactMap { $0["name"] }.joined(separator: ", ") ?? "No Authors"
        let url = paper["url"] as? String ?? "No URL"
        let year = paper["year"] as? Int ?? 0
        let venue = paper["venue"] as? String ?? "No Venue"

        return """
        Title: \(title)
        Abstract: \(abstract)
        Authors: \(authors)
        URL: \(url)
        Year: \(year)
        Venue: \(venue)
        """
    }

    func processWithGemini(prompt: String) async {
        do {
            // Replace with your actual Gemini API call
            apiOutput = "Gemini API call to be implemented. Prompt: \(prompt)"

            //Example of how to call gemini.
            //let response = try await model.generateContent(prompt)
            //apiOutput = response.text ?? "Gemini API error"

        } catch {
            apiOutput = "Gemini API error: \(error)"
        }
    }
}

struct GenerativeModel {
    var name: String,
        apiKey: String,
        generationConfig: String
    //Add your gemini api call functionality here.
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
