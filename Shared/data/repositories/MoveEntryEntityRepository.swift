//
//  SaveGameEntityRepository.swift
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

class MoveEntryEntityRepository: BaseRepository<MoveEntryEntity> {
  @discardableResult
  func create(
    position: Int32,
    locationNotation: String,
    type: MoveType,
    value: String
  ) -> MoveEntryEntity {
    let moveEntry = MoveEntryEntity(context: self.context)
    moveEntry.locationNotation = locationNotation
    moveEntry.type = type.rawValue
    moveEntry.position = position
    moveEntry.value = value

    return moveEntry;
  }

  func findAllBySaveGame(withId saveGameId: EntityID, withAdditionalPredicate additionalPredicate: NSPredicate? = nil) -> [MoveEntryEntity] {
    let findBySaveGamePredicate = NSPredicate(format: "saveGame == %@", saveGameId)
    let predicate = if (additionalPredicate == nil) {
      findBySaveGamePredicate
    } else {
      NSCompoundPredicate(andPredicateWithSubpredicates: [
        findBySaveGamePredicate,
        additionalPredicate ?? .none
      ])
    }

    return self.findManyBy(predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "position", ascending: true)])
  }
}
