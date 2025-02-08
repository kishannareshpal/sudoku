//
//  SaveGameEntityExtension.swift
//  sudoku
//
//  Created by Kishan Jadav on 04/01/2025.
//

import Foundation
import CoreData
import CloudKit.CKRecord

extension SaveGameEntity {
  func toOTASaveGameEntity() -> OTASaveGameEntity {
    .init(
      givenNotation: self.givenNotation,
      playerNotation: self.playerNotation,
      solutionNotation: self.solutionNotation,
      notesNotation: self.notesNotation,
      difficulty: self.difficulty,
      durationInSeconds: self.durationInSeconds,
      score: self.score,
      createdAt: self.createdAt,
      updatedAt: self.updatedAt
    )
  }
}
