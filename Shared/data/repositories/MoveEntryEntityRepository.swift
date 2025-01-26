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

class MoveEntryEntityDataRepository: DataRepository<MoveEntryEntity> {
  @discardableResult
  func create(
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
    
    return moveEntry;
  }

  func findAllBySaveGame(withId saveGameId: NSManagedObjectID) -> [MoveEntryEntity] {
    let fetchRequest: NSFetchRequest<MoveEntryEntity> = MoveEntryEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "saveGame == %@", saveGameId)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
    
    do {
      return try self.context.fetch(fetchRequest)
    } catch {
      return []
    }
  }
  
  func deleteAllMoves(fromPosition: Int32, forSaveGameId: NSManagedObjectID) {
    let fetchRequest: NSFetchRequest<MoveEntryEntity> = MoveEntryEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(
      format: "position >= %d AND saveGameId == %d",
      fromPosition,
      forSaveGameId
    )
    
    do {
      // Fetch objects matching the predicate
      let objectsToDelete = try self.context.fetch(fetchRequest)

      // Delete each object from the context
      for object in objectsToDelete {
        self.context.delete(object)
      }
    } catch {
      print("Failed to delete moves: \(error)")
    }
  }
}
