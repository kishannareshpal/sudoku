//
//  SaveGameEntityDataRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import Foundation

class SaveGameEntityDataRepository: DataRepository {
  static func hasAny() -> Bool {
    let request = SaveGameEntity.fetchRequest()
    request.predicate = .all
    request.fetchLimit = 1
    
    let count = (try? self.context.count(for: request)) ?? 0
    return count > 0
  }
  
  /// Find and return the last save game stored if any.
  static func findLast() -> SaveGameEntity? {
    let request = SaveGameEntity.fetchRequest()
    request.predicate = .all
    request.fetchLimit = 1
    request.sortDescriptors = []
    
    let result = (try? self.context.fetch(request)) ?? []
    return result.first
  }
  
  static func new(
    difficulty: Difficulty,
    givenNotation: BoardPlainStringNotation,
    solutionNotation: BoardPlainStringNotation,
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation
  ) -> Void {
    let saveGameEntity = self.findLast() ?? SaveGameEntity(context: self.context)

    saveGameEntity.difficulty = difficulty.rawValue
    saveGameEntity.givenNotation = givenNotation
    saveGameEntity.solutionNotation = solutionNotation
    saveGameEntity.durationInSeconds = 0
    saveGameEntity.playerNotation = playerNotation
    saveGameEntity.notesNotation = notesNotation
    saveGameEntity.createdAt = Date()
    saveGameEntity.updatedAt = Date()
    
    try? self.context.save()
  }
  
  static func incrementSessionDuration(lastSessionDurationInSeconds: Int64) -> Void {
    let lastSaveGameEntity = self.findLast()
    guard let lastSaveGameEntity = lastSaveGameEntity else {
      return
    }
    
    let now = Date()
    lastSaveGameEntity.updatedAt = now
    lastSaveGameEntity.durationInSeconds = lastSaveGameEntity.durationInSeconds + lastSessionDurationInSeconds
    try? self.context.save()
  }
  
  static func save(
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation
  ) -> Void {
    let lastSaveGameEntity = self.findLast()
    guard let lastSaveGameEntity = lastSaveGameEntity else {
      return
    }

    let now = Date()
    lastSaveGameEntity.updatedAt = now
    lastSaveGameEntity.playerNotation = playerNotation
    lastSaveGameEntity.notesNotation = notesNotation
    try? self.context.save()
  }
  
  static func clear() -> Void {
    let lastGame = self.findLast()
    guard let lastGame else {
      return
    }
    
    self.context.delete(lastGame)
  }
}
