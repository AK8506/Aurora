//
//  ContentView.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
// AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns

import SwiftUI

struct ContentView: View {
  @State private var inputText = ""
  @State private var apiOutput = ""
  @State private var isLoading = false
  @State private var sourceInfoText = ""
  @State private var showSourceInfo = false
  @State private var showingSourceInfoPopup = false  // New state for the popup

  // Model initialization with latest Gemini model
  let model = GenerativeModel(
    name: "gemini-1.5-pro",
    apiKey: "AIzaSyC83PbtVzqrGY5KmTzS1ow0a5V9wr_J0ns"
  )

  var body: some View {
    ZStack {  // ZStack allows overlay to appear on top of everything
      VStack {
        // Input field with search icon and underline
        HStack {
          TextField("Enter Semantic Scholar ID or Topic", text: $inputText)
            .padding(.vertical, 1)
            .padding(.horizontal, 30)
            .background(Color.clear)
            .overlay(
              HStack {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.purple)
                Spacer()
              }
              .padding(.leading, 8)
            )
            .padding(.horizontal)
        }

        // Underline for the input field
        Rectangle()
          .frame(height: 2)
          .foregroundColor(.purple)
          .padding(.bottom, 15)

        // Button to fetch data
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

        // Scrollable output text with toggle for source info
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            // Summary text
            if !apiOutput.isEmpty {
              Text(apiOutput)
                .padding(.bottom, 8)
            }

            // Show source info toggle
            if !sourceInfoText.isEmpty {
              Divider()
                .background(Color.gray.opacity(0.5))
                .padding(.vertical, 4)

              Button(action: {
                withAnimation {
                  showSourceInfo.toggle()
                }
              }) {
                HStack {
                  Text(
                    showSourceInfo
                      ? "Hide Source Information" : "Show Source Information"
                  )
                  .foregroundColor(.blue)

                  Image(
                    systemName: showSourceInfo ? "chevron.up" : "chevron.down"
                  )
                  .foregroundColor(.blue)
                }
              }

              if showSourceInfo {
                VStack(alignment: .leading, spacing: 6) {
                  Text(sourceInfoText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
                .transition(.opacity)
              }
            }
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(Color.gray.opacity(0.1))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.black, lineWidth: 2)
          )
          .padding()

          // Source info button - only shown when data is available
          if !sourceInfoText.isEmpty {
            Button(action: {
              showingSourceInfoPopup = true  // Show the popup instead
            }) {
              HStack {
                Image(systemName: "info.circle")
                  .foregroundColor(.blue)
                Text("Info about the source")
                  .foregroundColor(.blue)
                  .underline()
              }
            }
            .padding(.leading, 16)
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
      .padding()
      
      // Overlay for the source info popup
      if showingSourceInfoPopup {
        Color.black.opacity(0.4)
          .edgesIgnoringSafeArea(.all)
          .onTapGesture {
            showingSourceInfoPopup = false
          }
        
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text("Source Information")
              .font(.headline)
              .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
              showingSourceInfoPopup = false
            }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .font(.title2)
            }
          }
          
          Divider()
          
          ScrollView {
            Text(sourceInfoText)
              .font(.body)
              .foregroundColor(.primary)
          }
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .shadow(radius: 8)
        )
        .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.6)
        .transition(.scale)
        .animation(.easeInOut, value: showingSourceInfoPopup)
      }
    }
  }

  // Function to handle fetching data based on input
  func fetchDataFromAPI() async {
    if inputText.hasPrefix("ARXIV:") || inputText.count == 40 {
      await fetchFromSemanticScholarByID()
    } else {
      await fetchFromSemanticScholarBySearch()
    }
  }

  // Fetch data from Semantic Scholar by ID
  func fetchFromSemanticScholarByID() async {
    let urlString =
      "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,abstract,authors,url,year,venue"
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
      if let json = try JSONSerialization.jsonObject(with: data)
        as? [[String: Any]],
        let firstPaper = json.first
      {
        let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
        sourceInfoText = formattedOutput
        let geminiPrompt =
          "Summarize the following paper information in 3 sentences: \(formattedOutput)"
        await processWithGemini(prompt: geminiPrompt)
      } else {
        apiOutput = "Could not parse Semantic Scholar response."
        sourceInfoText = ""
      }
    } catch {
      apiOutput = "Error fetching data from Semantic Scholar: \(error)"
      sourceInfoText = ""
    }
  }

  // Fetch data from Semantic Scholar by search
  func fetchFromSemanticScholarBySearch() async {
    guard
      let encodedQuery = inputText.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed)
    else {
      apiOutput = "Invalid search query."
      return
    }

    let urlString =
      "https://api.semanticscholar.org/graph/v1/paper/search?query=\(encodedQuery)&fields=title,abstract,authors,url,year,venue"
    guard let url = URL(string: urlString) else {
      apiOutput = "Invalid URL."
      return
    }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let json = try JSONSerialization.jsonObject(with: data)
        as? [String: Any],
        let dataArray = json["data"] as? [[String: Any]],
        let firstPaper = dataArray.first
      {
        let formattedOutput = formatSemanticScholarResponse(paper: firstPaper)
        sourceInfoText = formattedOutput
        let geminiPrompt =
          "Summarize the following paper information in 3 sentences: \(formattedOutput)"
        await processWithGemini(prompt: geminiPrompt)
      } else {
        apiOutput = "Could not parse Semantic Scholar search response."
        sourceInfoText = ""
      }
    } catch {
      apiOutput = "Error fetching data from Semantic Scholar search: \(error)"
      sourceInfoText = ""
    }
  }

  // Format the Semantic Scholar response
  func formatSemanticScholarResponse(paper: [String: Any]) -> String {
    let title = paper["title"] as? String ?? "No Title"
    let abstract = paper["abstract"] as? String ?? "No Abstract"
    let authors =
      (paper["authors"] as? [[String: String]])?.compactMap { $0["name"] }
      .joined(separator: ", ") ?? "No Authors"
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

// Fully implemented GenerativeModel struct with Gemini API functionality
struct GenerativeModel {
  let name: String
  let apiKey: String
  let baseURL = "https://generativelanguage.googleapis.com"

  // Generation configuration
  var temperature: Double = 0.2
  var maxOutputTokens: Int = 1024
  var topK: Int = 40
  var topP: Double = 0.95

  func generateContent(_ prompt: String) async throws -> String {
    let endpoint = "\(baseURL)/v1/models/\(name):generateContent?key=\(apiKey)"

    guard let url = URL(string: endpoint) else {
      throw URLError(.badURL)
    }

    // Create the request payload
    let requestBody: [String: Any] = [
      "contents": [
        [
          "role": "user",
          "parts": [
            ["text": prompt]
          ],
        ]
      ],
      "generationConfig": [
        "temperature": temperature,
        "maxOutputTokens": maxOutputTokens,
        "topK": topK,
        "topP": topP,
      ],
    ]

    // Create and configure the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

    // Send the request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Check the response status code
    guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    else {
      // Try to extract error message if available
      if let errorJson = try? JSONSerialization.jsonObject(with: data)
        as? [String: Any],
        let error = errorJson["error"] as? [String: Any],
        let message = error["message"] as? String
      {
        throw NSError(
          domain: "GeminiAPI",
          code: (response as? HTTPURLResponse)?.statusCode ?? 0,
          userInfo: [NSLocalizedDescriptionKey: message])
      }
      throw URLError(.badServerResponse)
    }

    // Parse the response
    guard
      let json = try? JSONSerialization.jsonObject(with: data)
        as? [String: Any],
      let candidates = json["candidates"] as? [[String: Any]],
      let firstCandidate = candidates.first,
      let content = firstCandidate["content"] as? [String: Any],
      let parts = content["parts"] as? [[String: Any]],
      let firstPart = parts.first,
      let text = firstPart["text"] as? String
    else {
      throw NSError(
        domain: "GeminiAPI", code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
    }

    return text
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
