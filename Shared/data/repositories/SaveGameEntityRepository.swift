//
//  SaveGameEntityDataRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import Foundation

class SaveGameEntityDataRepository: DataRepository {  
  func create(
    difficulty: Difficulty,
    givenNotation: BoardPlainStringNotation,
    solutionNotation: BoardPlainStringNotation,
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation
  ) -> Void {
    let saveGameEntity = self.findCurrent() ?? SaveGameEntity(context: self.context)
    
    saveGameEntity.moveIndex = -1
    saveGameEntity.difficulty = difficulty.rawValue
    saveGameEntity.givenNotation = givenNotation
    saveGameEntity.solutionNotation = solutionNotation
    saveGameEntity.durationInSeconds = 0
    saveGameEntity.score = 0
    saveGameEntity.playerNotation = playerNotation
    saveGameEntity.notesNotation = notesNotation
    saveGameEntity.createdAt = Date()
    saveGameEntity.updatedAt = Date()
    saveGameEntity.moves = []
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: saveGameEntity.toOTASaveGameEntity())
      
    } catch {
      print("Failed to save the new game: \(error)")
      return
    }
  }
  
  
  
  
  
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
    request.relationshipKeyPathsForPrefetching = ["moves"]
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

    saveGameEntity.moveIndex = -1
    saveGameEntity.difficulty = difficulty.rawValue
    saveGameEntity.givenNotation = givenNotation
    saveGameEntity.solutionNotation = solutionNotation
    saveGameEntity.durationInSeconds = 0
    saveGameEntity.score = 0
    saveGameEntity.playerNotation = playerNotation
    saveGameEntity.notesNotation = notesNotation
    saveGameEntity.createdAt = Date()
    saveGameEntity.updatedAt = Date()
    saveGameEntity.moves = []
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: saveGameEntity.toOTASaveGameEntity())
      
    } catch {
      print("Failed to save the new game: \(error)")
      return
    }
  }
  
  static func updateDuration(seconds: Int64) -> Void {
    let currentSaveGameEntity = self.findCurrent()
    guard let currentSaveGameEntity = currentSaveGameEntity else {
      return
    }
    
    let now = Date()
    currentSaveGameEntity.updatedAt = now
    currentSaveGameEntity.durationInSeconds = seconds
    
    do {
      try self.context.save()
      
      SharedSaveGameManager.instance
        .share(entity: currentSaveGameEntity.toOTASaveGameEntity())
      
    } catch {
      print("Failed to save the increment for session duration: \(error)")
      return
    }
  }
  
  static func updateMoveIndex(_ newPosition: Int32) -> Void {
    let currentSaveGameEntity = self.findCurrent()
    guard let currentSaveGameEntity = currentSaveGameEntity else {
      return
    }
    
    let now = Date()
    currentSaveGameEntity.updatedAt = now
    currentSaveGameEntity.moveIndex = newPosition
    
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
    score: Int64?,
    duration: Int64?
  ) -> Void {
    let currentSaveGameEntity = self.findCurrent()
    guard let currentSaveGameEntity = currentSaveGameEntity else { return }

    let now = Date()
    currentSaveGameEntity.updatedAt = now
    currentSaveGameEntity.playerNotation = playerNotation
    currentSaveGameEntity.notesNotation = notesNotation
    
    if let score = score {
      currentSaveGameEntity.score = score
    }

    if let duration = duration {
      currentSaveGameEntity.durationInSeconds = duration
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
  
  static func delete() -> Void {
    let currentGame = self.findCurrent()
    guard let currentGame else {
      return
    }
    
    self.context.delete(currentGame)
  }
}
