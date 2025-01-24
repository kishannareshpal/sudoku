//
//  SaveGameEntityDataRepository.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import CoreData
import Foundation

// History process:
// ----------------
// Inserts a number
// - As the last index:
//   Makes a move, and increases index
// - Anywhere:
//   Undo, decreases the index
//   - Then makes a move, clears everything after the index
//     Inserts a move, updates to next index
//   Redo, increases the index
//   - Then makes a move, clears everything after the index
//     Inserts a move, updates to next index

class MoveEntryEntityDataRepository: DataRepository {
  static func findAllForSaveGame(withId saveGameId: NSManagedObjectID) -> [MoveEntryEntity] {
    let fetchRequest: NSFetchRequest<MoveEntryEntity> = MoveEntryEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "saveGame == %@", saveGameId)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
    
    do {
      let entries = try self.context.fetch(fetchRequest)
      return entries
    } catch {
      return []
    }
  }
  
  @discardableResult
  static func create(
    position: Int32,
    locationNotation: String,
    type: MoveType,
    value: String
  ) -> MoveEntryEntity? {
    let moveEntry = MoveEntryEntity(context: self.context)
    moveEntry.locationNotation = locationNotation
    moveEntry.type = type.rawValue
    moveEntry.position = position
    moveEntry.value = value
    
    do {
      try self.context.save()
      return moveEntry

    } catch {
      print("Failed to save move entry: \(error.localizedDescription)")
      return nil
    }
  }
  
  static func deleteAllEntriesAfterAndIncluding(position: Int32) -> Void {
    let entriesAfterPositionFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MoveEntryEntity")
    entriesAfterPositionFetch.predicate = NSPredicate(format: "position >= %d", position)
    
    let deleteRequest = NSBatchDeleteRequest(
      fetchRequest: entriesAfterPositionFetch
    )
    
    try? self.context.execute(deleteRequest)
    try? self.context.save()
  }
  
  static func deleteAll() -> Void {
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "MoveEntryEntity")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

    try! self.context.execute(deleteRequest)
    try! self.context.save()
  }
}
