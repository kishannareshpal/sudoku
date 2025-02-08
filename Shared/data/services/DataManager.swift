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
  let moveEntriesService: MoveEntryEntityService

  private let cloudSaveGameRepository: CloudSaveGameRepository
  private let saveGameEntityRepository: SaveGameEntityRepository
  private let moveEntryEntityRepository: MoveEntryEntityRepository
  
  // Private initializer to prevent direct instantiation
  private init(context: NSManagedObjectContext) {
    self.context = context
    
    // Repositories
    self.saveGameEntityRepository = SaveGameEntityRepository(context: context)
    self.moveEntryEntityRepository = MoveEntryEntityRepository(context: context)
    self.cloudSaveGameRepository = CloudSaveGameRepository()
    
    // Services
    self.saveGamesService = SaveGameEntityService(
      repository: self.saveGameEntityRepository,
      moveEntryRepository: self.moveEntryEntityRepository,
      cloudSaveGameRepository: self.cloudSaveGameRepository
    )

    self.moveEntriesService = MoveEntryEntityService(
      repository: self.moveEntryEntityRepository
    )
  }
  
  func persist() throws -> Void {
    try self.context.save()
  }
}
