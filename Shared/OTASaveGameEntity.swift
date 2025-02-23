//
//  OTASaveGameEntity.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation

@available(*, deprecated, message: "Using CloudKit exclusively")
public struct OTASaveGameEntity: Codable {
  var givenNotation: BoardPlainStringNotation?
  var playerNotation: BoardPlainStringNotation?
  var solutionNotation: BoardPlainStringNotation?
  var notesNotation: BoardPlainNoteStringNotation?
  var difficulty: String?
  var durationInSeconds: Int64 = 0
  var score: Int64 = 0
  var createdAt: Date?
  var updatedAt: Date?
  

  func toJSON() -> String {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601

    do {
      let data = try encoder.encode(self)
      return String(data: data, encoding: .utf8) ?? "{}"
    } catch {
      print("Failed to encode OTASaveGameEntity: \(error)")
      return "{}"
    }
  }
  
  // Static method to decode the entity from JSON
  static func fromJSON(_ json: String) -> OTASaveGameEntity? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
      let data = Data(json.utf8)
      return try decoder.decode(OTASaveGameEntity.self, from: data)
    } catch {
      print("Failed to decode OTASaveGameEntity: \(error)")
      return nil
    }
  }
}
