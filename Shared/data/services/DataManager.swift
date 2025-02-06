//
//  SharedEntityServicesManager.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

import Foundation
import CoreData

final class DataManager {
  /// The shared entity service manager object for use in the app.
  static let `default` = DataManager(
    context: AppDataProvider.shared.container.viewContext
  )

  // View context
  let context: NSManagedObjectContext

  let saveGamesService: SaveGameEntityService
  let usersService: UserEntityService
  let moveEntriesService: MoveEntryEntityService
  
  private let userEntityRepository: UserEntityRepository
  private let saveGameEntityRepository: SaveGameEntityRepository
  private let moveEntryEntityRepository: MoveEntryEntityRepository
  
  // Private initializer to prevent direct instantiation
  private init(context: NSManagedObjectContext) {
    self.context = context
    self.userEntityRepository = UserEntityRepository(context: context)
    self.saveGameEntityRepository = SaveGameEntityRepository(context: context)
    self.moveEntryEntityRepository = MoveEntryEntityRepository(context: context)
    
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
