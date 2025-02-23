//
//  SaveGameEntityData.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation
import CloudKit
import CoreData

// On load: CloudKit -> Core Data (local) -> UI
// On save: UI -> Core Data (local) -> CloudKit

class CloudSaveGameRepository: BaseCloudRepository {
  private let RECORD_TYPE = "SaveGames"
  private let RECORD_ID = "savegame"

  let ACTIVE_SAVE_GAME_CHANGED_NOTIFICATION_KEY: CKSubscription.ID = "active-savegames-changed"
  
  init() {
    super.init(recordType: self.RECORD_TYPE)
  }
  
  func findActiveSaveGame() async -> CKRecord? {
    guard await isCloudAvailable() else {
      return nil
    }
    
    let cloudRecord = await self.findOneBy(
      predicate: NSPredicate(format: "active == 1")
    )

    return cloudRecord
  }
  
  func subscribeToActiveSaveGameChanges() async -> Void {
    guard await isCloudAvailable() else {
      return
    }
    
    if let _ = try? await self.database.subscription(
      for: self.ACTIVE_SAVE_GAME_CHANGED_NOTIFICATION_KEY
    ) {
      // Subscription already exists.
      print("Already subscribed for cloud active savegames changes!")
      return
    }
    
    let subscription = CKQuerySubscription(
      recordType: self.RECORD_TYPE,
      predicate: NSPredicate(format: "active == 1"),
      subscriptionID: ACTIVE_SAVE_GAME_CHANGED_NOTIFICATION_KEY,
      options: [
        .firesOnRecordCreation,
        .firesOnRecordUpdate,
        .firesOnRecordDeletion
      ]
    )
    
    // Only send silent notifications
    let notificationInfo = CKSubscription.NotificationInfo()
    notificationInfo.shouldSendContentAvailable = true
    subscription.notificationInfo = notificationInfo
    
    do {
      try await self.database.save(subscription)
      print("Subscribed to cloud active savegames changes!")
    } catch(let error) {
      print("Error subscribing to cloud active savegames changes: \(error.localizedDescription)")
    }
  }
  
  func create(from saveGameEntity: SaveGameEntity) async -> Void {
    guard await isCloudAvailable() else {
      return
    }
    
    let recordID = CKRecord.ID(recordName: RECORD_ID)
    let newCloudRecord = CKRecord(recordType: self.RECORD_TYPE, recordID: recordID)
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
    
    // Replace the previous save game
    let operation = CKModifyRecordsOperation(
      recordsToSave: [newCloudRecord]
    )

    operation.isAtomic = true
    operation.savePolicy = .allKeys

    operation.modifyRecordsResultBlock = { result in
      switch result {
      case .success:
        print("Successfully created a new game in the cloud.")
        
      case .failure(let error):
        print(
          "Something went wrong while attempting to create a new game in the cloud: \(error.localizedDescription)"
        )
      }
    }

    self.database.add(operation)
  }

  func update(
    playerNotation: BoardPlainStringNotation? = nil,
    notesNotation: BoardPlainNoteStringNotation? = nil,
    movesNotation: BoardPlainMoveStringNotation? = nil,
    score: Int64? = nil,
    duration: Int64? = nil,
    moveIndex: Int64? = nil,
    updatedAt: Date,
    replace: Bool = false
  ) async -> Void {
    guard await isCloudAvailable() else {
      return
    }
    
    guard let cloudSaveGameRecord = await self.findActiveSaveGame() else {
      return
    }
    
    // Keys and values to consider for update
    let updates: [String: Any?] = [
      "playerNotation": playerNotation,
      "notesNotation": notesNotation,
      "movesNotation": movesNotation,
      "score": score,
      "durationInSeconds": duration,
      "moveIndex": moveIndex,
      "onDeviceUpdatedAt": updatedAt,
    ]
    updates.forEach { key, value in
      if let value {
        cloudSaveGameRecord[key] = value as? CKRecordValue
      }
    }
    
    let operation = CKModifyRecordsOperation(
      recordsToSave: [cloudSaveGameRecord]
    )
    operation.savePolicy = .changedKeys
    operation.modifyRecordsResultBlock = { result in
      switch result {
      case .success:
        print("Successfully updated save game on cloud.")

      case .failure(let error):
        print(
          "Conflict detected while updating save game on cloud. \(error.localizedDescription)"
        )
      }
    }

    self.database.add(operation)
  }
  
  /// Check iCloud account status (whether it has access to the apps private database).
  func isCloudAvailable() async -> Bool {
    // If user prefers to be offline, by enabling the option in settings, then respect that.
    let userPrefersBeingOffline = UserDefaults.standard.bool(
      forKey: UserDefaultKey.offline.rawValue
    )
    if userPrefersBeingOffline {
      print("User preffers being offline.")
      return false
    }
    
    
    // User did not choose to be offline, check actual cloud status
    do {
      let accountStatus = try await self.container.accountStatus()
      let isAvailable = accountStatus == .available
      print("Cloud is available? \(isAvailable ? "Yes" : "No")")
      return isAvailable
      
    } catch(let error) {
      print("Failed to determine cloud availability: \(error)")
      return false
    }
  }
}
