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
  
  let context = AppDataProvider.shared.container.viewContext
  
  let saveGamesService: SaveGameEntityService
  let usersService: UserEntityService
  let moveEntriesService: MoveEntryEntityService
  
  private let userEntityRepository: UserEntityRepository
  private let saveGameEntityRepository: SaveGameEntityRepository
  private let moveEntryEntityRepository: MoveEntryEntityRepository
  
  // Private initializer to prevent direct instantiation
  private init() {
    self.userEntityRepository = UserEntityRepository(context: self.context)
    self.saveGameEntityRepository = SaveGameEntityRepository(context: self.context)
    self.moveEntryEntityRepository = MoveEntryEntityRepository(context: self.context)
    
    // Initializes the save game entity service
    self.saveGamesService = SaveGameEntityService(
      repository: self.saveGameEntityRepository,
      userRepository: self.userEntityRepository,
      moveEntryRepository: self.moveEntryEntityRepository
    )

    self.moveEntriesService = MoveEntryEntityService(
      repository: self.moveEntryEntityRepository
    )
    
    self.usersService = UserEntityService(
      repository: self.userEntityRepository,
      saveGameRepository: saveGameEntityRepository
    )
  }
  
  func persist() throws -> Void {
    try self.context.save()
  }
}
