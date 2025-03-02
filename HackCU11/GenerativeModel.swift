//
//  GenerativeModel.swift
//  HackCU11
//
//  Created by Akshay Patnaik on 3/1/25.
//

import Foundation

struct GenerativeModel {
  let name: String
  let apiKey: String
  let baseURL = "https://generativelanguage.googleapis.com"
  
  // Generation configuration
  var temperature: Double = 0.2
  var maxOutputTokens: Int = 1024
  var topK: Int = 40
  var topP: Double = 0.95
  
  //    func generateContent(_ prompt: String) async throws -> String {
  //        let endpoint = "\(baseURL)/v1/models/\(name):generateContent?key=\(apiKey)"
  //
  //        guard let url = URL(string: endpoint) else {
  //            throw URLError(.badURL)
  //        }
  //
  //        let requestBody: [String: Any] = [
  //            "contents": [
  //                [
  //                    "role": "user",
  //                    "parts": [["text": prompt]]
  //                ]
  //            ],
  //            "generationConfig": [
  //                "temperature": temperature,
  //                "maxOutputTokens": maxOutputTokens,
  //                "topK": topK,
  //                "topP": topP
  //            ]
  //        ]
  //
  //        var request = URLRequest(url: url)
  //        request.httpMethod = "POST"
  //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  //        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
  //
  //        let (data, response) = try await URLSession.shared.data(for: request)
  //
  //        guard let httpResponse = response as? HTTPURLResponse,
  //              (200...299).contains(httpResponse.statusCode) else {
  //            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
  //               let error = errorJson["error"] as? [String: Any],
  //               let message = error["message"] as? String {
  //                throw NSError(domain: "GenerativeAPI", code: httpResponse?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: message])
  //            }
  //            throw URLError(.badServerResponse)
  //        }
  //
  //        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
  //              let candidates = json["candidates"] as? [[String: Any]],
  //              let firstCandidate = candidates.first,
  //              let content = firstCandidate["content"] as? [String: Any],
  //              let parts = content["parts"] as? [[String: Any]],
  //              let firstPart = parts.first,
  //              let text = firstPart["text"] as? String else {
  //            throw NSError(domain: "GenerativeAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
  //        }
  //
  //        return text
  //    }
  
  func generateContent(_ prompt: String) async throws -> String {
      let endpoint = "\(baseURL)/v1/models/\(name):generateContent?key=\(apiKey)"
      
      guard let url = URL(string: endpoint) else {
          throw URLError(.badURL)
      }
      
      let requestBody: [String: Any] = [
          "contents": [
              [
                  "role": "user",
                  "parts": [["text": prompt]]
              ]
          ],
          "generationConfig": [
              "temperature": temperature,
              "maxOutputTokens": maxOutputTokens,
              "topK": topK,
              "topP": topP
          ]
      ]
      
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
          if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
             let error = errorJson["error"] as? [String: Any],
             let message = error["message"] as? String {
              throw NSError(domain: "GenerativeAPI", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: message])
          }
          throw URLError(.badServerResponse)
      }
      
      guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let firstCandidate = candidates.first,
            let content = firstCandidate["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let firstPart = parts.first,
            let text = firstPart["text"] as? String else {
          throw NSError(domain: "GenerativeAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
      }
      
      return text
  }

}
