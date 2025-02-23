//
//  BaseRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import CloudKit

class BaseCloudRepository {
  private static let CONTAINER_NAME = "iCloud.com.kishannareshpal.sudoku"
  internal let container = CKContainer(identifier: BaseCloudRepository.CONTAINER_NAME)
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
    let records = await self.findManyBy(
      predicate: predicate,
      sortDescriptors: sortDescriptors,
      limit: 1
    )
    
    return records.first
  }
  
  func findAll(
    sortDescriptors: [NSSortDescriptor]? = nil,
    limit: Int? = nil
  ) async -> [CKRecord] {
    let query = CKQuery(recordType: self.recordType, predicate: .all)
    
    if let sortDescriptors {
      query.sortDescriptors = sortDescriptors
    }
    
    return await self.fetchManyAsync(query: query, limit: limit)
  }
  
  func findManyBy(
    predicate: NSPredicate,
    sortDescriptors: [NSSortDescriptor]? = nil,
    limit: Int? = nil
  ) async -> [CKRecord] {
    let query = CKQuery(recordType: self.recordType, predicate: predicate)
    
    if let sortDescriptors {
      query.sortDescriptors = sortDescriptors
    }
    
    return await self.fetchManyAsync(query: query, limit: limit)
  }
  
  private func fetchManyAsync(query: CKQuery, limit: Int? = nil) async -> [CKRecord] {
    return await withCheckedContinuation { continuation in
      var records: [CKRecord] = []

      let operation = CKQueryOperation(query: query)
      if let limit {
        operation.resultsLimit = limit
      }
      
      // This block is called once per record found
      operation.recordMatchedBlock = { (_, matchedResult) in
        switch matchedResult {
        case .success(let record):
          records.append(record)

        case .failure(let error):
          print("Failed to fetch record: \(error)")
        }
      }
      
      // When the operation is complete:
      operation.queryResultBlock = { (_) in
        continuation.resume(returning: records)
      }

      self.database.add(operation)
    }
  }
}


