//
//  AppDataProvider.swift
//  App
//
//  Created by Kishan Jadav on 26/08/2024.
//

import CoreData
import Foundation

class AppDataProvider: ObservableObject {
  static let shared = AppDataProvider(inMemory: ProcessInfo().isXcodePreview)
  
  let container = NSPersistentContainer(name: "AppDataModel")
  
  private init(inMemory: Bool = false) {
    if inMemory {
      // Configure the persistent store to use in-memory storage
      let description = NSPersistentStoreDescription()
      description.url = URL(fileURLWithPath: "/dev/null")
      container.persistentStoreDescriptions = [description]
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error {
        // Check if the error is related to migration
        print("Failed to load Core Data. Probably due to migration error. Attempting to reset the store.")
        self.deletePersistentStore(at: storeDescription.url)
        
        // Attempt to reload the persistent store
        self.container.loadPersistentStores { retryStoreDescription, retryError in
          if let retryError = retryError {
            fatalError("Core Data failed to load even after deletion \(retryError.localizedDescription)")
          } else {
            print("Core Data successfully reloaded after deletion. \(error.localizedDescription)")
          }
        }
      }
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
  
  private func deletePersistentStore(at url: URL?) {
      guard let url = url else {
        print("Persistent store URL is nil, cannot delete.")
        return
      }
      
      let fileManager = FileManager.default
      do {
        try fileManager.removeItem(at: url)
        print("Persistent store successfully deleted at \(url).")
      } catch {
        print("Failed to delete persistent store at \(url): \(error.localizedDescription)")
      }
    }
}
