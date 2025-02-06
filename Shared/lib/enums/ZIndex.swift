//
//  ZIndex.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2023.
//

public struct ZIndex {
  static let board = 1.0

  struct Cell {
    static let cursor = 2.0
    
    static let noteBackgroundShape = 2.5
    static let noteText = 3.0
    
    static let invalidNumberShape = 3.5 // Must be behind the numberText
    static let numberText = 4.0 // Must be above all
  }
}
