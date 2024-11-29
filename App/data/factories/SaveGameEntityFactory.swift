//
//  Factory.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import CoreData
import Foundation

extension SaveGameEntity {
  static func make(
    context: NSManagedObjectContext,
    difficulty: Difficulty = Difficulty.easy,
    playerNotation: BoardPlainStringNotation = BoardNotationHelper.emptyPlainStringNotation(),
    givenNotation: BoardPlainStringNotation = BoardNotationHelper.emptyPlainStringNotation(),
    solutionNotation: BoardPlainStringNotation = BoardNotationHelper.emptyPlainStringNotation(),
    updatedAt: Date = Date(),
    createdAt: Date = Date()
  ) -> SaveGameEntity {
    let entity = SaveGameEntity.init(context: context)
    entity.difficulty = difficulty.rawValue
    entity.playerNotation = playerNotation
    entity.givenNotation = givenNotation
    entity.solutionNotation = solutionNotation
    entity.createdAt = createdAt
    entity.updatedAt = updatedAt

    return entity
  }
}
