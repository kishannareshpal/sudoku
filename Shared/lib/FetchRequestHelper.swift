//
//  FetchRequestHelper.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/01/2025.
//

import CoreData

class FetchRequestHelper {
  static func buildFetchRequestWithRelationship<TEntity: NSManagedObject>(
    entityName: String? = nil,
    predicate: NSPredicate,
    relationshipKeyPathsForPrefetching: [String]?,
    sortDescriptors: [NSSortDescriptor] = []
  ) -> NSFetchRequest<TEntity> {
    // Use the provided entity name or infer from the generic type.
    let finalEntityName = entityName ?? String(describing: TEntity.self)
    let fetchRequest = NSFetchRequest<TEntity>(entityName: finalEntityName)
    fetchRequest.predicate = predicate
    fetchRequest.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
    fetchRequest.sortDescriptors = sortDescriptors
    return fetchRequest
  }
}
