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
  static func findCurrent() -> SaveGameEntity? {
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
    let saveGameEntity = self.findCurrent() ?? SaveGameEntity(context: self.context)

    saveGameEntity.difficulty = difficulty.rawValue
    saveGameEntity.givenNotation = givenNotation
    saveGameEntity.solutionNotation = solutionNotation
    saveGameEntity.durationInSeconds = 0
    saveGameEntity.score = 0
    saveGameEntity.playerNotation = playerNotation
    saveGameEntity.notesNotation = notesNotation
    saveGameEntity.createdAt = Date()
    saveGameEntity.updatedAt = Date()
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: saveGameEntity.toOTASaveGameEntity())
      
    } catch {
      print("Failed to save the new game: \(error)")
      return
    }
  }
  
  static func incrementSessionDuration(lastSessionDurationInSeconds: Int64) -> Void {
    let currentSaveGameEntity = self.findCurrent()
    guard let currentSaveGameEntity = currentSaveGameEntity else {
      return
    }
    
    let now = Date()
    currentSaveGameEntity.updatedAt = now
    currentSaveGameEntity.durationInSeconds += lastSessionDurationInSeconds
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: currentSaveGameEntity.toOTASaveGameEntity())
      
    } catch {
      print("Failed to save the increment for session duration: \(error)")
      return
    }
  }
  
  static func save(
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation,
    scoreToAdd: Int64
  ) -> Void {
    let currentSaveGameEntity = self.findCurrent()
    guard let currentSaveGameEntity = currentSaveGameEntity else {
      return
    }

    let now = Date()
    currentSaveGameEntity.updatedAt = now
    currentSaveGameEntity.playerNotation = playerNotation
    currentSaveGameEntity.notesNotation = notesNotation
    currentSaveGameEntity.score += scoreToAdd
    if currentSaveGameEntity.score < 0 {
      currentSaveGameEntity.score = 0
    }
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: currentSaveGameEntity.toOTASaveGameEntity())

    } catch {
      print("Failed to save game: \(error)")
      return
    }
  }
  
  static func clear() -> Void {
    let currentGame = self.findCurrent()
    guard let currentGame else {
      return
    }
    
    self.context.delete(currentGame)
  }
}
