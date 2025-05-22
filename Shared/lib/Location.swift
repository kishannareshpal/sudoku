//
//  Location.swift
//  sudoku
//
//  Created by Kishan Jadav on 10/04/2022.
//

import Foundation

public struct Location: Equatable {
  private(set) var row: Int
  private(set) var col: Int

  private(set) var index: Int
  private(set) var indexOrientation: LocationIndexOrientation
  
  var grid: (col: Int, row: Int) {
    // Important note: Swift integer division discards the remainder,
    // so its implicitly applying a floor(x) hence I don't need to explicitly define it.
    let col = self.col / 3
    let row = self.row / 3
    
    return (col, row)
  }
  
  var notation: String {
    return "\(row)\(col)"
  }
  
  static var zero: Location {
    return Location(row: 0, col: 0)
  }
  
  init(notation: String, orientation: LocationIndexOrientation = LocationIndexOrientation.topToBottom) {
    precondition(
      Location.validateNotationFormat(notation),
      "Provided notation \(notation) must have a valid format where it consists of two digits, the first being a row index and the second being a column index"
    )
    
    let rowValueIndex = notation.startIndex // the first character in the notation should be a row
    let colValueIndex = notation.index(notation.startIndex, offsetBy: 1) // the second character in the notation should be a col
    
    let row = Int(String(notation[rowValueIndex])) ?? 0
    let col = Int(String(notation[colValueIndex])) ?? 0
    
    precondition(
      0..<Board.rowsCount ~= row,
      "Provided row index \(row) must be within the range of number of rows"
    )
    precondition(
      0..<Board.colsCount ~= col,
      "Provided column index \(col) must be within the range of number of columns"
    )
    
    self.row = row
    self.col = col
    self.indexOrientation = orientation
    self.index = Location.indexFrom(
      col: col,
      row: row,
      forOrientation: orientation
    )
  }
  
  init(row: Int, col: Int, orientation: LocationIndexOrientation = LocationIndexOrientation.topToBottom) {
    precondition(
      0..<Board.rowsCount ~= row,
      "Provided row index \(row) must be within the range of number of rows"
    )
    precondition(
      0..<Board.colsCount ~= col,
      "Provided column index \(col) must be within the range of number of columns"
    )
    
    self.row = row
    self.col = col
    self.indexOrientation = orientation
    self.index = Location.indexFrom(
      col: col,
      row: row,
      forOrientation: orientation
    )
  }
  
  /// Initializes a new  ``Location``instance a given index based on the current ``orientation`` setting.
  /// - Parameter crownValue: a number between `0` to `colsCount * rowsCount` (in a `9x9` grid this would be `0 - 80`, or in a `3x3` grid this would be `0 - 8`)
  /// - Returns: A new ``Location`` instance related to the given index for the orientation.
  init(
    index: Int,
    orientation: LocationIndexOrientation,
    colsCount: Int = Board.colsCount,
    rowsCount: Int = Board.rowsCount
  ) {
    let maximumAllowedIndex = (rowsCount * colsCount) - 1
    
    precondition(
      0...maximumAllowedIndex ~= index,
      "Provided index \(index) must be within the range of 0 and \(maximumAllowedIndex) inclusive."
    )
    
    let col: Int = Location.colFrom(
      index: index,
      forOrientation: orientation,
      colsCount: colsCount
    )
    let row: Int = Location.rowFrom(
      index: index,
      forOrientation: orientation,
      rowsCount: rowsCount
    )
    
    self.init(
      row: row,
      col: col,
      orientation: orientation
    )
  }
  
  func clone() -> Location {
    return Location(index: self.index, orientation: self.indexOrientation)
  }
  
  mutating func moveToNextIndex(wrap: Bool = true) -> Void {
    let newIndex = self.index.advanced(by: 1)
    
    if (wrap) {
      // If reached the end, wrap around and move to the beginning and continue from there:
      self.index = newIndex % Board.cellsCount

    } else {
      // If not wrapping, ensure you're not moving out of bounds:
      let canMove = newIndex <= (Board.cellsCount - 1)
      if (canMove) {
        self.index = newIndex
      }
    }
    
    self.col = Location.colFrom(
      index: self.index,
      forOrientation: self.indexOrientation
    )
    
    self.row = Location.rowFrom(
      index: self.index,
      forOrientation: self.indexOrientation
    )
  }
  
  mutating func moveToPreviousIndex(wrap: Bool = true) -> Void {
    let newIndex = self.index.advanced(by: -1)
    
    if (newIndex < 0) {
      if (!wrap) {
        // If reached the beginning, and not wrapping, there's no place to go.
        // Do nothing.
        return;
      }

      // Wrap around:
      self.index = Board.cellsCount + newIndex
    
    } else {
      // Can go backwards, so move:
      self.index = newIndex
    }
    
    self.col = Location.colFrom(
      index: self.index,
      forOrientation: self.indexOrientation
    )
    
    self.row = Location.rowFrom(
      index: self.index,
      forOrientation: self.indexOrientation
    )
  }
  
  mutating func moveDown(wrap: Bool = true) -> Void {
    let nextRowIndex = self.row + 1
    if (wrap) {
      // If reached the end, wrap around and move to the beginning and continue from there:
      self.row = nextRowIndex % Board.rowsCount

    } else {
      // If not wrapping, ensure you're not moving out of bounds:
      let canMove = nextRowIndex <= (Board.rowsCount - 1)
      if (canMove) {
        self.row = nextRowIndex
      }
    }
  }
  
  mutating func moveUp(wrap: Bool = true) -> Void {
    let nextRowIndex = self.row - 1
    if (wrap) {
      // If reached the end, wrap around and move to the beginning and continue from there:
      self.row = nextRowIndex % Board.rowsCount

    } else {
      // If not wrapping, ensure you're not moving out of bounds:
      let canMove = nextRowIndex >= 0
      if (canMove) {
        self.row = nextRowIndex
      }
    }
  }
  
  mutating func moveRight(wrap: Bool = true) -> Void {
    let nextColIndex = self.col + 1
    if (wrap) {
      // If reached the end, wrap around and move to the beginning and continue from there:
      self.col = nextColIndex % Board.colsCount

    } else {
      // If not wrapping, ensure you're not moving out of bounds:
      let canMove = nextColIndex <= (Board.colsCount - 1)
      if (canMove) {
        self.col = nextColIndex
      }
    }
  }
  
  mutating func moveLeft(wrap: Bool = true) -> Void {
    let nextColIndex = self.col - 1
    if (wrap) {
      // If reached the end, wrap around and move to the beginning and continue from there:
      self.col = nextColIndex % Board.colsCount

    } else {
      // If not wrapping, ensure you're not moving out of bounds:
      let canMove = nextColIndex >= 0
      if (canMove) {
        self.col = nextColIndex
      }
    }
  }
  
  mutating func changeOrientation(to orientation: LocationIndexOrientation) -> Void {
    self.indexOrientation = orientation
  }
  
  /// Returns whether two ``Location`` instances are equal.
  /// - Parameters:
  ///   - lhs: The left hand side value of the comparison
  ///   - rhs: The right hand side value of the comparison
  /// - Returns: `true` if equal, otherwise `false`
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return (lhs.row == rhs.row) && (lhs.col == rhs.col)
  }
  
  /// Returns whether this ``Location`` instance has a given notation.
  /// - Parameters:
  ///   - lhs: The left hand side value of the comparison
  ///   - rhs: The right hand side value of the comparison
  /// - Returns: `true` if equal, otherwise `false`
  public static func == (lhs: Location, rhs: String) -> Bool {
    return lhs.notation == rhs
  }
  
  
  /// Initializes a new ``Location`` instance for a random place in a grid. Default to 9x9 grid, set by the ``in`` param.
  ///
  /// - Precondition: Bounds for ``range`` must be a number between 0 and 8 inclusive.
  /// - Parameters:
  ///   - in: Limits the range for both row and column on generation. Default: `0...8` (9x9 grid)
  /// - Returns: A new ``Location`` instance for a random place in the grid.
  static func random(in range: ClosedRange<Int> = 0...8) -> Location {
    precondition(0...8 ~= range.lowerBound, "Range lowerbound must be a number between 0 and 8 inclusive.")
    precondition(0...8 ~= range.upperBound, "Range upperbound must be a number between 0 and 8 inclusive.")
    let randomRow = Int.random(in: range)
    let randomCol = Int.random(in: range)
    
    return Location(row: randomRow, col: randomCol)
  }
  
  static func indexFrom(col: Int, row: Int, forOrientation orientation: LocationIndexOrientation) -> Int {
    switch orientation {
    case .leftToRight:
      return row * Board.colsCount + col
    case .topToBottom:
      return col * Board.rowsCount + row
    }
  }
  
  static func colFrom(index: Int, forOrientation orientation: LocationIndexOrientation, colsCount: Int = Board.colsCount) -> Int {
    switch orientation {
    case .leftToRight:
      return index % colsCount
    case .topToBottom:
      return index / colsCount
    }
  }
  
  static func rowFrom(index: Int, forOrientation orientation: LocationIndexOrientation, rowsCount: Int = Board.rowsCount) -> Int {
    switch orientation {
    case .leftToRight:
      return index / rowsCount
    case .topToBottom:
      return index % rowsCount
    }
  }
  
  static func validateNotationFormat(_ notation: String) -> Bool {
    guard notation.count == 2 else {
      return false
    }
    
    guard notation.allSatisfy({ $0.isNumber }) else {
      return false
    }
    
    return true
  }
}
