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
  func create(
    forUser user: UserEntity,
    difficulty: Difficulty,
    givenNotation: BoardPlainStringNotation,
    solutionNotation: BoardPlainStringNotation,
    playerNotation: BoardPlainStringNotation,
    notesNotation: BoardPlainNoteStringNotation
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
    
    saveGame.user = user
    user.activeSaveGame = saveGame

    try self.persist()
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
