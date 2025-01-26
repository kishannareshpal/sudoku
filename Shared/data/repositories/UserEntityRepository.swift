//
//  UserEntity.swift
//  sudoku
//
//  Created by Kishan Jadav on 24/01/2025.
//

import CoreData
import Foundation

class UserEntityRepository: BaseRepository<UserEntity> {
  func findOrCreate(forDevice device: Device, prefetchRelationships: [String]? = nil) throws -> UserEntity {
    let existingUser = self.findOneBy(
      predicate: NSPredicate(format: "device == %@", device.rawValue),
      prefetchRelationships: prefetchRelationships
    )
    
    // Has an existing user, return it
    if let existingUser {
      return existingUser
    }
    
    // No existing user found, create one
    let user = UserEntity(context: self.context)
    user.activeSaveGame = nil
    user.device = device.rawValue
    
    try self.persist()
    return user
  }
  
  func hasActiveSaveGame(userId: EntityID) -> Bool {
    let user = self.findById(userId)

    return user?.activeSaveGame != nil ? true : false
  }
  
  func setActiveSaveGame(
    _ saveGame: SaveGameEntity,
    forUserId userId: EntityID
  ) -> Void {
    let user = self.findById(userId)
    
    if let user {
      user.activeSaveGame = saveGame
    }
    
    try! self.persist()
  }
  
  func unsetActiveGame(
    fromUserId: EntityID
  ) -> Void {
    let user = self.findById(fromUserId)
    
    if let user {
      user.activeSaveGame = nil
    }
    
    try! self.persist()
  }
}
