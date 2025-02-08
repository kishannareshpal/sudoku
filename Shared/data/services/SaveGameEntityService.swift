//
//  SaveGameEntityData.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation

class SaveGameEntityService {
  let repository: SaveGameEntityRepository
  let moveEntryRepository: MoveEntryEntityRepository
  let cloudSaveGameRepository: CloudSaveGameRepository
  
  init(
    repository: SaveGameEntityRepository,
    moveEntryRepository: MoveEntryEntityRepository,
    cloudSaveGameRepository: CloudSaveGameRepository
  ) {
    self.repository = repository
    self.moveEntryRepository = moveEntryRepository
    self.cloudSaveGameRepository = cloudSaveGameRepository
  }
  
  func sync() async {
    if true {
      return
    }
    
    let cloudSaveGameRecord = await self.cloudSaveGameRepository.findActiveSaveGame()
    let localSaveGame = self.findActiveLocalSaveGame()
    
    // We don't have a cloud game
    guard let cloudSaveGameRecord else {
      if let localSaveGame {
        // However we have a local game. Sync this up to the cloud
        await self.cloudSaveGameRepository.create(from: localSaveGame)
        print("Merged cloud changes: Cloud game created to match local")

      } else {
        // No games found on both ends
        print("No active cloud or local save games found to merge.")
      }

      return
    }
  
    // --- Merge strategy ---
    let cloudSaveGame = SaveGame.fromCloudKitRecord(cloudSaveGameRecord)

    // We don't have a local save game but have one in the cloud
    // - Sync the cloud version to the device.
    guard let localSaveGame else {
      self.repository.create(from: cloudSaveGame)
      print("Using cloud game and stored it locally, as this device did not have one")
      return
    }
    
    // We have both a local and a cloud save game, however they
    // are different games.
    // - Ask the user on how they want to proceed
    if (cloudSaveGame.givenNotation != localSaveGame.givenNotation) {
      // TODO: ASK USER WHICH ONE THEY WANT TO KEEP.
      print("Could not merge cloud changes: Different games. Needs user intervention –– TODO")
      return
    }
    
    // Both local and cloud save games are identical
    if (cloudSaveGame.updatedAt == localSaveGame.updatedAt) {
      print("In sync!")
      return
    }

    // The cloud version is newer, update the local save game to match
    if (cloudSaveGame.updatedAt > localSaveGame.updatedAt!) {
      localSaveGame.playerNotation = cloudSaveGame.playerNotation
      localSaveGame.notesNotation = cloudSaveGame.notesNotation
      localSaveGame.score = cloudSaveGame.score
      
      // Keep the longest gameplay duration record
      localSaveGame.durationInSeconds = max(
        localSaveGame.durationInSeconds,
        cloudSaveGame.durationInSeconds
      )
      
      // Reset history
      // - TODO: Maybe support syncing history, later
      localSaveGame.moves = []
      localSaveGame.moveIndex = -1
      
      try! self.repository.persist()
      print("Merged cloud changes: Local game updated to match cloud")
      return
    }
    
    // The local version is newer than the one in the cloud, update the cloud
    await self.cloudSaveGameRepository.update(
      playerNotation: localSaveGame.playerNotation,
      notesNotation: localSaveGame.notesNotation,
      score: localSaveGame.score,
      duration: localSaveGame.durationInSeconds,
      moveIndex: localSaveGame.moveIndex,
      updatedAt: localSaveGame.updatedAt!
    )
    
    print("Merged cloud changes: Cloud game updated to match local")
  }
  
  func findActiveLocalSaveGame() -> SaveGameEntity? {
    return self.repository.findActiveSaveGame()
  }
  
  func detachActiveSaveGame() async -> Void {
    // Unset locally
    self.repository.unsetActiveGame()
    
    // Unset on the cloud
    await self.cloudSaveGameRepository.unsetActiveGame()
  }
  
  @discardableResult
  func createNewSaveGame(
    difficulty: Difficulty,
    persist: Bool = true
  ) async throws -> SaveGameEntity {
    let puzzleGenerator = PuzzleGenerator()
    puzzleGenerator.generate()
    
    let serializedGivenNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.given)
    let serializedSolutionNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.solution)
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzleGenerator.notes)

    // Save locally
    let newGameEntity = try self.repository.create(
      difficulty: difficulty,
      givenNotation: serializedGivenNotation,
      solutionNotation: serializedSolutionNotation,
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation,
      persist: persist
    )
    
    // Sync to the cloud
    await self.cloudSaveGameRepository.create(from: newGameEntity)
    
    return newGameEntity
  }
  
  func autoSave(
    _ saveGameId: EntityID,
    puzzle: Puzzle,
    duration: Int64? = nil,
    score: Int64? = nil
  ) throws -> Void {
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
    
    let updatedLocalSaveGame = try self.repository.update(
      saveGameId,
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation,
      score: score,
      duration: duration
    )
    
//    Task {
//      await self.cloudSaveGameRepository.update(
//        playerNotation: serializedPlayerNotation,
//        notesNotation: serializedNotesNotation,
//        score: score,
//        duration: duration,
//        updatedAt: updatedLocalSaveGame.updatedAt!
//      )
//    }

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
        format: "position >= %d",
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
