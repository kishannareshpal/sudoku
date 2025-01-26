//
//  DataRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData

class DataRepository<TEntity: NSManagedObject> {
  internal let context = AppDataProvider.shared.container.viewContext

  func findById(_ id: NSManagedObjectID) -> TEntity? {
    do {
      let entity = try self.context.existingObject(with: id) as? TEntity
      return entity;
    } catch {
      return nil
    }
  }
  
  func destroyAll() -> Void {
    let entityName = String(describing: TEntity.self)
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(
      entityName: entityName
    )
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
    
    do {
      try self.context.execute(deleteRequest)
    } catch {
      print("Failed to destroy all \(entityName) objects: \(error)")
    }
  }
  
  func persist() throws {
    try self.context.save()
  }
}
