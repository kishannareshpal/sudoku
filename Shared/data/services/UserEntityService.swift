//
//  UserEntityDataService.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import Foundation

class UserEntityService {
  let repository: UserEntityRepository
  let saveGameRepository: SaveGameEntityRepository
  
  init(
    repository: UserEntityRepository,
    saveGameRepository: SaveGameEntityRepository
  ) {
    self.repository = repository
    self.saveGameRepository = saveGameRepository
  }
  
  var currentUserId: EntityID {
    let serializedUserId = UserDefaults.standard.string(forKey: UserDefaultKey.userId.rawValue)!
    
    return AppDataProvider.shared.container
      .persistentStoreCoordinator
      .managedObjectID(
        forURIRepresentation: URL(string: serializedUserId)!
      )!
  }
  
  func findCurrentUser(prefetchRelationships: [String]? = nil) -> UserEntity {
    let user = self.repository.findOneBy(
      predicate: NSPredicate(
        format: "SELF == %@ AND device == %@",
        self.currentUserId,
        currentDevice.rawValue
      ),
      prefetchRelationships: prefetchRelationships
    )!
    
    return user
  }
  
  func ensureCurrentUserExists() throws -> Void {
    let user = try self.repository.findOrCreate(forDevice: currentDevice)

    let serializedUserId = user.objectID.uriRepresentation().absoluteString
    UserDefaults.standard.set(serializedUserId, forKey: UserDefaultKey.userId.rawValue)
  }
  
  func findActiveSaveGame() -> SaveGameEntity? {
    let user = self.findCurrentUser(prefetchRelationships: ["activeSaveGame"])
    return user.activeSaveGame
  }
  
  func detachActiveSaveGame() throws -> Void {
    self.repository.unsetActiveGame(fromUserId: self.currentUserId)
  }
}
