//
//  BaseRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData

typealias EntityID = NSManagedObjectID

class BaseRepository<TEntity: NSManagedObject> {
  internal let context: NSManagedObjectContext

  init(context: NSManagedObjectContext) {
    self.context = context;
  }
  
  func findById(_ id: EntityID, prefetchRelationships: [String]? = nil) -> TEntity? {
    do {
      let entityName = String(describing: TEntity.self)
      let fetchRequest = NSFetchRequest<TEntity>(entityName: entityName)
      fetchRequest.predicate = NSPredicate(format: "self == %@", id)
      
      // Prefetch relationships if requested
      if let prefetchRelationships {
        fetchRequest.relationshipKeyPathsForPrefetching = prefetchRelationships
      }
      
      let results = try self.context.fetch(fetchRequest)
      return results.first // Since we expect only one result by ID

    } catch {
      print("Failed to fetch \(TEntity.self) with id \(id): \(error)")
      return nil
    }
  }
  
  func findOneBy(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil, prefetchRelationships: [String]? = nil) -> TEntity? {
    let entities = self.findManyBy(predicate: predicate, limit: 1, sortDescriptors: sortDescriptors, prefetchRelationships: prefetchRelationships)
    return entities.first
  }
  
  func findManyBy(predicate: NSPredicate, limit: Int? = nil, sortDescriptors: [NSSortDescriptor]? = nil, prefetchRelationships: [String]? = nil) -> [TEntity] {
    let entityName = String(describing: TEntity.self)
    let fetchRequest = NSFetchRequest<TEntity>(entityName: entityName)
    fetchRequest.predicate = predicate
    
    // Prefetch relationships if requested
    if let prefetchRelationships {
      fetchRequest.relationshipKeyPathsForPrefetching = prefetchRelationships
    }
    
    if let limit {
      fetchRequest.fetchLimit = limit
    }
    
    if let sortDescriptors {
      fetchRequest.sortDescriptors = sortDescriptors
    }

    do {
      let results = try self.context.fetch(fetchRequest)
      return results

    } catch {
      print("Failed to fetch \(entityName) with predicate \(predicate): \(error)")
      return []
    }
  }
  
  func deleteById(_ id: EntityID) -> Void {
    let object = self.findById(id)
    guard let object else {
      return
    }
    
    self.context.delete(object)
    try! self.persist()
  }
  
  func deleteAll(predicate: NSPredicate? = nil) -> Void {
    let entityName = String(describing: TEntity.self)
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(
      entityName: entityName
    )
    deleteFetch.predicate = predicate

    do {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
      try self.context.execute(deleteRequest)
      print("Deleted all with predicate \(predicate.debugDescription)")
    } catch {
      print("Failed to delete \(entityName) objects: \(error)")
    }
    
    try! self.persist()
  }

  func persist() throws {
    DispatchQueue.main.async {
      try! self.context.save()
    }
  }
  
  
}


