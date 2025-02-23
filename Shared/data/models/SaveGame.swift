//
//  SaveGame.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/02/2025.
//

import Foundation
import CloudKit

struct SaveGame {
  var difficulty: String
  var givenNotation: String
  var solutionNotation: String
  var durationInSeconds: Int64
  var score: Int64
  var playerNotation: String
  var notesNotation: String
  var movesNotation: String
  var updatedAt: Date
  var createdAt: Date
  var active: Bool
  var moveIndex: Int64
  
  static func fromCloudKitRecord(_ record: CKRecord) -> SaveGame {
    return SaveGame(
      difficulty: record["difficulty"]!,
      givenNotation: record["givenNotation"]!,
      solutionNotation: record["solutionNotation"]!,
      durationInSeconds: record["durationInSeconds"] ?? 0,
      score: record["score"] ?? 0,
      playerNotation: record["playerNotation"]!,
      notesNotation: record["notesNotation"]!,
      movesNotation: record["movesNotation"] ?? "",
      updatedAt: record["onDeviceUpdatedAt"]!,
      createdAt: record["onDeviceCreatedAt"]!,
      active: Bool(truncating: record["active"] as? NSNumber ?? 0),
      moveIndex: record["moveIndex"] ?? -1
    )
  }
}
