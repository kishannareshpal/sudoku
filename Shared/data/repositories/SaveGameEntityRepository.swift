//
//  SaveGameEntityRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import Foundation


enum SaveGameEntityRepositoryErrors: Error {
  case saveGameNotFound
  case userNotFound
}

class SaveGameEntityRepository: BaseRepository<SaveGameEntity> {
  func hasActiveSaveGame() -> Bool {
    return self.findOneBy(
      predicate: NSPredicate(format: "active == %d", true)
    ) != nil ? true : false
  }
  
  func setActiveSaveGame(_ saveGame: SaveGameEntity) -> Void {
    saveGame.active = true
    try! self.persist()
  }
  
  func unsetActiveGame() -> Void {
    let activeSaveGame = self.findActiveSaveGame()
    if let activeSaveGame {
      activeSaveGame.active = false
    }
    
    try! self.persist()
  }
  
  func findActiveSaveGame() -> SaveGameEntity? {
    return self.findOneBy(
      predicate: NSPredicate(format: "active == %d", true)
    )
  }
  
  @discardableResult
  func create(from saveGameStruct: SaveGame) -> SaveGameEntity {
    let entity = SaveGameEntity(context: self.context)

    entity.difficulty = saveGameStruct.difficulty
    entity.givenNotation = saveGameStruct.givenNotation
    entity.solutionNotation = saveGameStruct.solutionNotation
    entity.durationInSeconds = saveGameStruct.durationInSeconds
    entity.score = saveGameStruct.score
    entity.playerNotation = saveGameStruct.playerNotation
    entity.notesNotation = saveGameStruct.notesNotation
    entity.createdAt = saveGameStruct.createdAt
    entity.updatedAt = saveGameStruct.updatedAt
    entity.updatedAt = saveGameStruct.updatedAt
    entity.moveIndex = saveGameStruct.moveIndex

    try! self.persist()
    return entity
  }
  
  func create(
    difficulty: Difficulty,
    givenNotation: BoardPlainStringNotation,
    solutionNotation: BoardPlainStringNotation,
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation,
    persist: Bool = true
  ) throws -> SaveGameEntity {
    let saveGame = SaveGameEntity(context: self.context)

    saveGame.moveIndex = -1
    saveGame.difficulty = difficulty.rawValue
    saveGame.givenNotation = givenNotation
    saveGame.solutionNotation = solutionNotation
    saveGame.durationInSeconds = 0
    saveGame.score = 0
    saveGame.playerNotation = playerNotation
    saveGame.notesNotation = notesNotation
    saveGame.createdAt = Date()
    saveGame.updatedAt = Date()
    saveGame.moves = []
    
    // New games are automatically marked as active
    saveGame.active = true

    if persist {
      try self.persist()
    }

    return saveGame
  }

  func updateDuration(for saveGameId: EntityID, seconds: Int64) throws -> Void {
    guard let saveGame = self.findById(saveGameId) else {
      throw SaveGameEntityRepositoryErrors.saveGameNotFound
    }
    
    let now = Date()
    saveGame.updatedAt = now
    saveGame.durationInSeconds = seconds
    
    try self.persist()
  }

  @discardableResult
  func update(
    _ saveGameId: EntityID,
    playerNotation: BoardPlainStringNotation? = nil,
    notesNotation: BoardPlainNoteStringNotation? = nil,
    score: Int64? = nil,
    duration: Int64? = nil,
    moveIndex: Int32? = nil
  ) throws -> SaveGameEntity {
    guard let saveGame = self.findById(saveGameId) else {
      throw SaveGameEntityRepositoryErrors.saveGameNotFound
    }
    
    let now = Date()
    saveGame.updatedAt = now

    if let playerNotation {
      saveGame.playerNotation = playerNotation
    }
    
    if let notesNotation {
      saveGame.notesNotation = notesNotation
    }
    
    if let score {
      saveGame.score = score
    }
    
    if let duration {
      saveGame.durationInSeconds = duration
    }
    
    if let moveIndex {
      saveGame.moveIndex = moveIndex
    }
    
    try! self.persist()

    return saveGame
  }
}
