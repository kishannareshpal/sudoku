class FetchRequestHelper {
  static func buildFetchRequestWithRelationship<TEntity: NSManagedObject>(
    entityName: String,
    predicate: NSPredicate,
    relationshipKeyPathsForPrefetching: [String]?,
    sortDescriptors: [NSSortDescriptor] = []
  ) -> NSFetchRequest<TEntity> {
    let fetchRequest = NSFetchRequest<TEntity>(entityName: entityName)
    fetchRequest.predicate = predicate
    fetchRequest.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
    fetchRequest.sortDescriptors = sortDescriptors
    return fetchRequest
  }
}