//
//  SaveGameEntityData.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation
import CloudKit
import CoreData

// TODO:
// Generic interfacing model:
// CloudKit -> Local DB -> Screen
// CloudKit <- Local DB <- Screen

class CloudSaveGameRepository: BaseCloudRepository {
  private let RECORD_TYPE = "SaveGames"
  
  init() {
    super.init(recordType: RECORD_TYPE)
  }
  
  func findActiveSaveGame() async -> CKRecord? {
    let cloudRecord = await self.findOneBy(
      predicate: NSPredicate(format: "active == 1")
    )
    
    guard let cloudRecord else {
      return nil
    }
    
    return cloudRecord
  }
  
  func create(from saveGameEntity: SaveGameEntity) async -> Void {
    let newCloudRecord = CKRecord(recordType: self.RECORD_TYPE)

    newCloudRecord.setValuesForKeys([
      "active": saveGameEntity.active,
      "difficulty": saveGameEntity.difficulty!,
      "durationInSeconds": saveGameEntity.durationInSeconds,
      "givenNotation": saveGameEntity.givenNotation!,
      "moveIndex": saveGameEntity.moveIndex,
      "notesNotation": saveGameEntity.notesNotation!,
      "playerNotation": saveGameEntity.playerNotation!,
      "score": saveGameEntity.score,
      "solutionNotation": saveGameEntity.solutionNotation!,
      "onDeviceUpdatedAt": saveGameEntity.updatedAt!,
      "onDeviceCreatedAt": saveGameEntity.createdAt!
    ])

    do {
      try await self.database.save(newCloudRecord)
    } catch let error {
      print("Failed to create a new save game in the cloud: \(error)")
    }
  }
  
  func unsetActiveGame() async -> Void {
    guard let cloudSaveGameRecord = await self.findActiveSaveGame() else {
      return
    }
    
    cloudSaveGameRecord["active"] = 0
    
    do {
      try await self.database.save(cloudSaveGameRecord)
    } catch let error {
      print("Failed to unset the active save game from cloud: \(error)")
    }
  }

  func update(
    playerNotation: BoardPlainStringNotation? = nil,
    notesNotation: BoardPlainNoteStringNotation? = nil,
    score: Int64? = nil,
    duration: Int64? = nil,
    moveIndex: Int32? = nil,
    updatedAt: Date
  ) async -> Void {
    guard let cloudSaveGameRecord = await self.findActiveSaveGame() else {
      return
    }
    
    let updates: [String: Any?] = [
      "playerNotation": playerNotation,
      "notesNotation": notesNotation,
      "score": score,
      "durationInSeconds": duration,
      "moveIndex": moveIndex,
      "onDeviceUpdatedAt": updatedAt
    ]
    
    updates.forEach { key, value in
      // Ignore any value that is nil
      if let value {
        cloudSaveGameRecord[key] = value as? CKRecordValue
      }
    }
    
    do {
      try await self.database.save(cloudSaveGameRecord)
    } catch let error as CKError where error.code == .serverRecordChanged {
      guard let serverRecord = error.serverRecord else {
        print("Error: Missing server record in conflict resolution.")
        return
      }
      
      updates.forEach { key, value in
        if let value = value {
          cloudSaveGameRecord[key] = value as? CKRecordValue
        }
      }
      
      do {
        try await self.database.save(serverRecord)
      } catch {
        print("Error saving merged record: \(error)")
      }
    } catch {
      print("Error saving record: \(error)")
    }
  }
}
