//
//  BaseRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import CloudKit

class BaseCloudRepository {
  internal let container = CKContainer.default()
  internal let database: CKDatabase
  
  /// The name of the RecordType in CloudKit
  private let recordType: String

  init(recordType: String) {
    self.recordType = recordType
    self.database = container.privateCloudDatabase
  }
  
  func findOneBy(
    predicate: NSPredicate,
    sortDescriptors: [NSSortDescriptor]? = nil
  ) async -> CKRecord? {
    let query = CKQuery(recordType: self.recordType, predicate: predicate)
    if let sortDescriptors {
      query.sortDescriptors = sortDescriptors
    }
    
    return await self.fetchOneAsync(query: query)
  }
  
  private func fetchOneAsync(query: CKQuery) async -> CKRecord? {
    return await withCheckedContinuation { continuation in
      self.database.fetch(withQuery: query, inZoneWith: .default) { result in
        switch result {
        case .success((let matchedResults, _)):
          guard let firstResult = matchedResults.first else {
            continuation.resume(returning: nil)
            return
          }
          
          let (_, recordResult) = firstResult
          switch recordResult {
          case .success(let record):
            continuation.resume(returning: record)
            
          case .failure(_):
            continuation.resume(returning: nil)
          }
        case .failure(_):
          continuation.resume(returning: nil)
        }
      }
    }
  }
}


