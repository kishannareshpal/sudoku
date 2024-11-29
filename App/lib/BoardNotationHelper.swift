//
//  BoardNotation.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/08/2024.
//

import Foundation

/// Typealias representing a single row in the board grid notation.
typealias BoardGridNotationRow = [Int]

/// Typealias representing a single cell in the board grid note notation row.
typealias BoardGridNoteNotationCell = [Int]

/// Typealias representing a single row in the board grid note notation.
typealias BoardGridNoteNotationRow = [BoardGridNoteNotationCell]

/// Typealias representing the entire board grid notation.
typealias BoardGridNotation = [BoardGridNotationRow]

/// Typealias representing the plain string notation of the board.
typealias BoardPlainStringNotation = String

/// Typealias representing the plain string notation for notes on the board.
typealias BoardPlainNoteStringNotation = String

/// Typealias representing the parsed notes notation on the board.
typealias BoardGridNoteNotation = [BoardGridNoteNotationRow]

/// Typealias representing the plain integer notation of the board.
/// TODO: deprecate?
typealias BoardPlainIntNotation = [Int]


/// A helper structure for converting between different notations of a Sudoku board.
struct BoardNotationHelper {
  static func emptyGridNotation() -> BoardGridNotation {
    let cols = Array(repeating: 0, count: Board.colsCount)
    let rows = Array(repeating: cols, count: Board.rowsCount)
    return rows
  }
  
  static func emptyGridNoteNotation() -> BoardGridNoteNotation {
    // An array of 9 arrays containing 9 cols
    return Array(
      repeating: Array(repeating: [], count: Board.colsCount),
      count: Board.rowsCount
    )
  }
  
  static func emptyPlainIntNotation() -> BoardPlainIntNotation {
    return Array(repeating: 0, count: Board.cellsCount)
  }
  
  static func emptyPlainStringNotation() -> BoardPlainStringNotation {
    return Array(repeating: "0", count: Board.cellsCount).joined(separator: ",")
  }
  
  static func emptyPlainNoteStringNotation() -> BoardPlainNoteStringNotation {
    // Commas separating 81 (Board.cellsCount) empty spaces
    return String(repeating: ",", count: Board.cellsCount - 1)
  }
  
  static func toGridNoteNotation(
    from plainNoteStringNotation: BoardPlainNoteStringNotation
  ) -> BoardGridNoteNotation {
    var grid: BoardGridNoteNotation = []
    
    let plainRows = plainNoteStringNotation.split(separator: ",", omittingEmptySubsequences: false)
    
    (0..<Board.rowsCount).forEach { rowIndex in
      var row: BoardGridNoteNotationRow = []
      
      (0..<Board.colsCount).forEach { columnIndex in
        let colRowIndex = rowIndex * Board.colsCount + columnIndex
        let plainRow = plainRows[colRowIndex]
        
        var cellWithNotes: BoardGridNoteNotationCell = []
        
        plainRow.forEach { cellNoteRawValue in
          let cellNoteValue = Int(String(cellNoteRawValue))!
          if (cellNoteValue > 0) {
            cellWithNotes.append(cellNoteValue)
          }
        }
        
        row.append(cellWithNotes)
      }
      
      grid.append(row)
    }
    
    return grid
  }
  
  /// Converts a plain integer notation to a grid notation.
  ///
  /// - Parameter plainIntNotation: A list of integers representing the board in a flattened format.
  /// - Returns: A 2D array representing the grid notation of the board.
  static func toGridNotation(
    from plainIntNotation: BoardPlainIntNotation
  ) -> BoardGridNotation {
    var grid: BoardGridNotation = []
    
    (0..<Board.rowsCount).forEach { rowIndex in
      var row: BoardGridNotationRow = []
      
      (0..<Board.colsCount).forEach { columnIndex in
        let colRowIndex = rowIndex * Board.colsCount + columnIndex
        
        let value = Int(plainIntNotation[colRowIndex])
        row.append(value)
      }
      
      grid.append(row)
    }
    
    return grid;
  }

  /// Converts a plain string notation to a grid notation.
  ///
  /// - Parameter plainStringNotation: A string where integers are separated by commas, representing the board.
  /// - Returns: A 2D array representing the grid notation of the board.
  static func toGridNotation(
    from plainStringNotation: BoardPlainStringNotation
  ) -> BoardGridNotation {
    let plainIntNotation = self.toPlainIntNotation(from: plainStringNotation)

    return self.toGridNotation(from: plainIntNotation)
  }

  /// Converts a plain string notation to a plain integer notation.
  ///
  /// - Parameter plainStringNotation: A string where integers are separated by commas.
  /// - Returns: A list of integers extracted from the string.
  static func toPlainIntNotation(
    from plainStringNotation: BoardPlainStringNotation
  ) -> BoardPlainIntNotation {
    
    return plainStringNotation
      .components(separatedBy: ",")
      .map { numberString in
        return Int(numberString) ?? 0
      }
  }

  /// Converts a grid notation to a plain string notation.
  ///
  /// - Parameter gridNotation: A 2D array representing the board in grid notation.
  /// - Returns: A string where integers are separated by commas.
  static func toPlainStringNotation(
    from gridNotation: BoardGridNotation
  ) -> BoardPlainStringNotation {
    let plainIntNotation = self.toPlainIntNotation(from: gridNotation)
    
    // Convert each integer to a string and join them with commas
    return plainIntNotation.map(String.init).joined(separator: ",")
  }
  
  /// Converts a grid notes notation to a plain string notes notation.
  ///
  /// - Parameter noteGridNotation: A 2D array representing the board in grid notation.
  /// - Returns: A string where each row is represented by 9 characters, 0 (no note) to 9 indicating the value for each cell, separated by comma, to be translated from left-to-right, top-to-bottom.
  static func toPlainNoteStringNotation(
    from gridNoteNotation: BoardGridNoteNotation
  ) -> BoardPlainNoteStringNotation {
    var plainNoteNotation: BoardPlainNoteStringNotation = ""
    
    gridNoteNotation.forEach { row in
      row.forEach { cellNotes in
        cellNotes.forEach { cellNoteValue in
          plainNoteNotation.append(String(cellNoteValue))
        }
        
        plainNoteNotation.append(",")
      }
    }

    return plainNoteNotation
  }
  
  static func toPlainStringNotation(
    from plainIntNotation: BoardPlainIntNotation
  ) -> BoardPlainStringNotation {
    // Convert each integer to a string and join them with commas
    return plainIntNotation.map(String.init).joined(separator: ",")
  }
  
  /// Converts a grid notation to a plain integer notation.
  ///
  /// - Parameter gridNotation: A 2D array representing the board in grid notation.
  /// - Returns: A list of integers representing the flattened format of the board.
  static func toPlainIntNotation(
    from gridNotation: BoardGridNotation
  ) -> BoardPlainIntNotation {
    return gridNotation.flatMap { $0 }
  }
}
