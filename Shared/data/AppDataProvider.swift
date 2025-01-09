//
//  AppDataProvider.swift
//  App
//
//  Created by Kishan Jadav on 26/08/2024.
//

import CoreData
import Foundation

class AppDataProvider: ObservableObject {
  static let shared = AppDataProvider()
  static let sharedForPreview = AppDataProvider(inMemory: true)
  
  let container = NSPersistentContainer(name: "AppDataModel")
  
  private init(inMemory: Bool = false) {
    if inMemory {
      // Configure the persistent store to use in-memory storage
      let description = NSPersistentStoreDescription()
      description.url = URL(fileURLWithPath: "/dev/null")
      container.persistentStoreDescriptions = [description]
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error {
        fatalError("Core Data failed to load \(error.localizedDescription)")
      }
    }
  }
}
