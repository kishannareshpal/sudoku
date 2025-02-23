//
//  SaveGameEntityData.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation

enum SyncResult {
  case success, offline, conflict
}

class SaveGameEntityService {
  let repository: SaveGameEntityRepository
  let cloudSaveGameRepository: CloudSaveGameRepository
  
  private var syncTask: Task<Void, Never>? = nil
  private let debounceInterval: TimeInterval = 2 // in seconds
  private var syncDebounceTimer: Timer? = nil

  init(
    repository: SaveGameEntityRepository,
    cloudSaveGameRepository: CloudSaveGameRepository
  ) {
    self.repository = repository
    self.cloudSaveGameRepository = cloudSaveGameRepository
  }

  @discardableResult
  func sync(
    forceOverwriteLocalWithCloud: Bool = false,
    forceOverwriteCloudWithLocal: Bool = false
  ) async -> SyncResult {
    guard await self.cloudSaveGameRepository.isCloudAvailable() else {
      return .offline
    }
    
    let cloudSaveGameRecord = await self.cloudSaveGameRepository.findActiveSaveGame()
    let localSaveGame = self.findActiveLocalSaveGame()
    
    // We don't have games anywhere (cloud or local)
    if cloudSaveGameRecord == nil && localSaveGame == nil {
      print("No active cloud or local save games found to merge.")

      return .success
    }
    
    guard let cloudSaveGameRecord else {
      // We don't have a cloud game
      if let localSaveGame {
        // However we have a local game. Sync this up to the cloud
        await self.cloudSaveGameRepository.create(from: localSaveGame)
        print("Merged cloud changes: Cloud game created to match local")

      } else {
        // No games found on both ends
        print("No active cloud or local save games found to merge.")
      }

      return .success
    }

    let cloudSaveGame = SaveGame.fromCloudKitRecord(cloudSaveGameRecord)

    // We don't have a local save game but have one in the cloud
    // - Sync the cloud version to the device.
    guard let localSaveGame else {
      self.repository.create(from: cloudSaveGame)
      print("Using cloud game and stored it locally, as this device did not have one")
      return .success
    }
    
    // --- Manual-merge strategies ---

    // Both local and cloud save games are totally different
    if (cloudSaveGame.givenNotation != localSaveGame.givenNotation) {
      guard forceOverwriteCloudWithLocal || forceOverwriteLocalWithCloud else {
        // No action taken by the user. Action required!
        return .conflict
      }
      
      // Action has been taken by the user:
      if forceOverwriteLocalWithCloud {
        self.repository.unsetActiveGame()
        self.repository.create(from: cloudSaveGame)
        return .success
        
      } else if forceOverwriteCloudWithLocal {
        await self.cloudSaveGameRepository.create(from: localSaveGame)
        return .success
      }

      return .conflict
    }
    
    // --- Auto-merge strategies ---
    
    // Both local and cloud save games are identical
    if (cloudSaveGame.updatedAt == localSaveGame.updatedAt) {
      print("In sync! No need to do anything")
      return .success
    }

    // Update the older save game with the newer version
    if (cloudSaveGame.updatedAt > localSaveGame.updatedAt!) {
      // The cloud version is newer, update the local save game to match
      self.mergeLocalWithCloudSaveGame(
        localSaveGame: localSaveGame,
        cloudSaveGame: cloudSaveGame
      )
      print("Merged cloud changes: Local game updated to match cloud")

    } else {
      // The local version is newer than the one in the cloud, update the cloud
      await self.mergeCloudWithLocalSaveGame(
        localSaveGame: localSaveGame,
        cloudSaveGame: cloudSaveGame
      )
      print("Merged cloud changes: Cloud game updated to match local")
    }
    
    return .success
  }
  
  private func debounceSyncAsync() {
    // Cancel any existing timer
    self.syncDebounceTimer?.invalidate()
    
    // Pass necessary values to the closure explicitly
    let performSync = self.sync // Store a reference to the sync method
    
    self.syncDebounceTimer = Timer.scheduledTimer(withTimeInterval: self.debounceInterval, repeats: false) { _ in
      Task {
        await performSync(false, false)
      }
    }
  }
  
  private func mergeLocalWithCloudSaveGame(
    localSaveGame: SaveGameEntity,
    cloudSaveGame: SaveGame,
    replace: Bool = false
  ) {
    localSaveGame.playerNotation = cloudSaveGame.playerNotation
    localSaveGame.notesNotation = cloudSaveGame.notesNotation
    localSaveGame.movesNotation = cloudSaveGame.movesNotation
    localSaveGame.moveIndex = cloudSaveGame.moveIndex
    localSaveGame.score = cloudSaveGame.score
    
    // Keep the longest gameplay duration record
    localSaveGame.durationInSeconds = max(
      localSaveGame.durationInSeconds,
      cloudSaveGame.durationInSeconds
    )
    
    try! self.repository.persist()
  }
  
  private func mergeCloudWithLocalSaveGame(
    localSaveGame: SaveGameEntity,
    cloudSaveGame: SaveGame,
    replace: Bool = false
  ) async {
    await self.cloudSaveGameRepository.update(
      playerNotation: localSaveGame.playerNotation,
      notesNotation: localSaveGame.notesNotation,
      movesNotation: localSaveGame.movesNotation,
      score: localSaveGame.score,
      duration: localSaveGame.durationInSeconds,
      moveIndex: localSaveGame.moveIndex,
      updatedAt: localSaveGame.updatedAt!
    )
  }
  
  func subscribeToCloudActiveSaveGameChanges() async -> Void {
    await self.cloudSaveGameRepository.subscribeToActiveSaveGameChanges()
  }
  
  func findActiveLocalSaveGame() -> SaveGameEntity? {
    return self.repository.findActiveSaveGame()
  }
  
  func findActiveCloudSaveGame() async -> SaveGame? {
    let cloudSaveGameRecord = await self.cloudSaveGameRepository.findActiveSaveGame()
    guard let cloudSaveGameRecord else {
      return nil
    }
    
    return SaveGame.fromCloudKitRecord(cloudSaveGameRecord)
  }
  
  @discardableResult
  func createNewSaveGame(
    difficulty: Difficulty,
    detachPreviousGame: Bool = true,
    persist: Bool = true
  ) throws -> SaveGameEntity {
    if detachPreviousGame {
      self.repository.unsetActiveGame()
    }
    
    let puzzleGenerator = PuzzleGenerator()
    puzzleGenerator.generate()
    
    let serializedGivenNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.given)
    let serializedSolutionNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.solution)
    let serializedPlayerNotation = BoardNotationHelper.toPlainStringNotation(from: puzzleGenerator.player)
    let serializedNotesNotation = BoardNotationHelper.toPlainNoteStringNotation(from: puzzleGenerator.notes)
    let serializedMovesNotation = BoardNotationHelper.toPlainMoveStringNotation(from: puzzleGenerator.moves)

    // Save locally
    let newGameEntity = try self.repository.create(
      difficulty: difficulty,
      givenNotation: serializedGivenNotation,
      solutionNotation: serializedSolutionNotation,
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation,
      movesNotation: serializedMovesNotation,
      persist: persist
    )
    
    // Sync to the cloud asynchronously
    Task {
      await self.sync(forceOverwriteCloudWithLocal: true)
    }
    
    return newGameEntity
  }
  
  func autoSave(
    _ saveGameId: EntityID,
    puzzle: Puzzle? = nil,
    duration: Int64? = nil,
    score: Int64? = nil
  ) throws -> Void {
    let serializedPlayerNotation: BoardPlainStringNotation? = if let puzzle {
      BoardNotationHelper.toPlainStringNotation(from: puzzle.player)
    } else {
      nil
    }
    
    let serializedNotesNotation: BoardPlainNoteStringNotation? = if let puzzle {
      BoardNotationHelper.toPlainNoteStringNotation(from: puzzle.notes)
    } else {
      nil
    }
    
    let serializedMovesNotation: BoardPlainMoveStringNotation? = if let puzzle {
      BoardNotationHelper.toPlainMoveStringNotation(from: puzzle.moves)
    } else {
      nil
    }
    
    let moveIndex: Int64? = if let puzzle {
      Int64(puzzle.moveIndex)
    } else {
      nil
    }
    
    try self.repository.update(
      saveGameId,
      playerNotation: serializedPlayerNotation,
      notesNotation: serializedNotesNotation,
      movesNotation: serializedMovesNotation,
      score: score,
      duration: duration,
      moveIndex: moveIndex
    )
    
    // Sync with the cloud asynchronously
    self.debounceSyncAsync()

    print("Auto saved!")
  }
}
