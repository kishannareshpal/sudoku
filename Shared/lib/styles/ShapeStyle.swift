//
//  ShapeStyle.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation

struct ShapeStyle: Codable {
  var board: Board = Board()
  
  struct Board: Codable {
    var cell: Cell = Cell()
    
    struct Cell: Codable {
      var cursor: Cursor = Cursor()
      
      struct Cursor: Codable {
        var strokeWidth: CGFloat = 2.0
      }
    }
  }
}
