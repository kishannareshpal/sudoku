//
//  SharedEntityServicesManager.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

import Foundation

final class DataManager {
  /// The shared entity service manager object for the process.
  static let `default` = DataManager()
  
  private let userEntityRepository: UserEntityRepository
  private let saveGameEntityRepository: SaveGameEntityRepository
  private let moveEntryEntityRepository: MoveEntryEntityRepository
  
  let saveGame: SaveGameEntityService
  let user: UserEntityService
  let moveEntry: MoveEntryEntityService
  
  var currentSessionUserId: EntityID {
    return UserDefaults.standard.value(forKey: UserDefaultKey.userId.rawValue) as! EntityID
  }
  
  // Private initializer to prevent direct instantiation
  private init() {
    self.userEntityRepository = UserEntityRepository()
    self.saveGameEntityRepository = SaveGameEntityRepository(userRepository: userEntityRepository)
    self.moveEntryEntityRepository = MoveEntryEntityRepository()
    
    // Initializes the save game entity service
    self.saveGame = SaveGameEntityService(repository: self.saveGameEntityRepository)
    self.moveEntry = MoveEntryEntityService(repository: self.moveEntryEntityRepository)
    self.user = UserEntityService(repository: self.userEntityRepository)
  }
}
