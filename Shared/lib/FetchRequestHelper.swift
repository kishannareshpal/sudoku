//
//  FetchRequestHelper.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

import CoreData

class FetchRequestHelper {
  static func buildFetchRequest<TEntity: NSManagedObject>(
    entityName: String? = nil,
    predicate: NSPredicate,
    limit: Int? = nil,
    relationshipKeyPathsForPrefetching: [String]? = nil,
    sortDescriptors: [NSSortDescriptor] = []
  ) -> NSFetchRequest<TEntity> {
    // Use the provided entity name or infer from the generic type.
    let finalEntityName = entityName ?? String(describing: TEntity.self)
    let fetchRequest = NSFetchRequest<TEntity>(entityName: finalEntityName)
    fetchRequest.predicate = predicate
    
    if let limit {
      fetchRequest.fetchLimit = limit
    }
    
    if let relationshipKeyPathsForPrefetching {
      fetchRequest.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
    }

    fetchRequest.sortDescriptors = sortDescriptors
    return fetchRequest
  }
}
