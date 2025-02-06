//
//  SaveGameEntityData.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation

class SaveGameEntityService {
  let repository: SaveGameEntityRepository
  let userRepository: UserEntityRepository
  let moveEntryRepository: MoveEntryEntityRepository
  
  init(
    repository: SaveGameEntityRepository,
    userRepository: UserEntityRepository,
    moveEntryRepository: MoveEntryEntityRepository
  ) {
    self.repository = repository
    self.userRepository = userRepository
    self.moveEntryRepository = moveEntryRepository
  }
  
  @discardableResult
  func createNewSaveGame(difficulty: Difficulty) throws -> SaveGameEntity {
    let userId = self.userRepository.currentUserId
    
    let puzzleGenerator = PuzzleGenerator()
    puzzleGenerator.generate()
    
    let serializedGivenNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.given)
    let serializedSolutionNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.solution)
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzleGenerator.notes)
    
    let user = self.userRepository.findById(userId)!
    return try self.repository.create(
      forUser: user,
      difficulty: difficulty,
      givenNotation: serializedGivenNotation,
      solutionNotation: serializedSolutionNotation,
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation
    )
  }
  
  func autoSave(
    _ saveGameId: EntityID,
    puzzle: Puzzle,
    duration: Int64? = nil,
    score: Int64? = nil
  ) throws -> Void {
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
    
    try self.repository
      .update(
        saveGameId,
        playerNotation: serializedPlayerNotation,
        notesNotation: serializedNotesNotation,
        score: score,
        duration: duration
      )

    print("Auto saved!")
  }
  
  func addMove(
    _ saveGameId: EntityID,
    position: Int32,
    locationNotation: String,
    type: MoveType,
    value: String
  ) throws -> MoveEntryEntity? {
    let saveGame = self.repository.findById(saveGameId)
    guard let saveGame else {
      return nil;
    }
    
    let movesToDelete = self.moveEntryRepository.findAllBySaveGame(
      withId: saveGameId,
      withAdditionalPredicate: NSPredicate(
        format: "position >= %d AND saveGame == %@",
        position,
        saveGameId
      )
    )
    
    movesToDelete.forEach { move in
      DataManager.default.context.delete(move)
    }

    let moveEntry = self.moveEntryRepository.create(
      position: position,
      locationNotation: locationNotation,
      type: type,
      value: value
    )
    
    saveGame.moveIndex = position
    saveGame.addToMoves(moveEntry)
    try DataManager.default.persist()
    
    return moveEntry
  }
}
