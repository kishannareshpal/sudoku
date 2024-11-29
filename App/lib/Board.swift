//
//  Board.swift
//  Sudoku WatchKit Extension
//
//  Created by Kishan Jadav on 09/04/2022.
//

import Foundation

/// Represents the current board
public struct Board {
  static let rowSubgridsCount: Int = 3
  static let colSubgridsCount: Int = 3
  static let subgridsCount: Int = rowSubgridsCount * colSubgridsCount
  static let rowsCount: Int = 9
  static let colsCount: Int = 9
  static let cellsCount: Int = rowsCount * colsCount

  var puzzle: Puzzle
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity?) {
    self.puzzle = Puzzle(difficulty: difficulty, existingGame: existingGame)
    self.puzzle.generate()
  }
}
